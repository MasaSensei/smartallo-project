import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { trigger, transition, style, animate } from '@angular/animations';
import { ApiService } from '../../core/services/api.service';
import {
  SubscriptionPlan,
  SubscriptionTransaction,
} from '../../core/models/subscription.model';
import { SubscriptionFormComponent } from './components/subscription-form/subscription-form.component';

interface FormattedPlan extends SubscriptionPlan {
  parsedFeatures: string[];
}

@Component({
  selector: 'app-billing-control',
  standalone: true,
  imports: [CommonModule, FormsModule, SubscriptionFormComponent],
  templateUrl: './billing-control.component.html',
  styleUrls: ['./billing-control.component.scss'],
  animations: [
    trigger('fadeIn', [
      transition(':enter', [
        style({ opacity: 0, transform: 'translateY(10px)' }),
        animate(
          '300ms ease-out',
          style({ opacity: 1, transform: 'translateY(0)' }),
        ),
      ]),
    ]),
  ],
})
export class BillingControlComponent implements OnInit {
  plans = signal<FormattedPlan[]>([]);
  transactions = signal<SubscriptionTransaction[]>([]);
  activeTab = signal<'plans' | 'history'>('plans');

  showModal = signal<boolean>(false);
  selectedPlan = signal<SubscriptionPlan | undefined>(undefined);
  isLoading = signal<boolean>(false);

  // Toast signals
  toastMessage = signal<string | null>(null);
  toastType = signal<'success' | 'error'>('success');

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.refreshAllData();
  }

  refreshAllData() {
    this.loadPlans();
    this.loadTransactions();
  }

  loadPlans() {
    this.isLoading.set(true);
    // Pastikan path konsisten dengan backend Go kamu
    this.api.get<SubscriptionPlan[]>('/subscriptions/plans').subscribe({
      next: (data) => {
        const formatted = data.map((p) => ({
          ...p,
          parsedFeatures: Array.isArray(p.features) ? p.features : [],
        }));
        this.plans.set(formatted);
        this.isLoading.set(false);
      },
      error: () => {
        this.showToast('Gagal memuat master plan', 'error');
        this.isLoading.set(false);
      },
    });
  }

  loadTransactions() {
    this.api
      .get<SubscriptionTransaction[]>('/admin/subscriptions/transactions')
      .subscribe({
        next: (data) => this.transactions.set(data),
        error: () => this.showToast('Gagal memuat riwayat', 'error'),
      });
  }

  handleSave(payload: any) {
    const isEdit = !!this.selectedPlan();
    const id = this.selectedPlan()?.id;

    let rawFeatures = payload.features;
    let finalFeatures: string[] = [];

    if (Array.isArray(rawFeatures)) {
      // Kalau sudah array, tinggal pakai
      finalFeatures = rawFeatures;
    } else if (typeof rawFeatures === 'string') {
      // 1. Bersihkan string dari karakter yang sering nyangkut pas copy-paste
      let cleaned = rawFeatures.trim();

      // 2. Cek apakah user masukin format JSON manual (ada [ ])
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        try {
          finalFeatures = JSON.parse(cleaned);
        } catch (e) {
          // Jika JSON.parse gagal (format salah), paksa bersihkan bracketnya
          cleaned = cleaned.substring(1, cleaned.length - 1);
        }
      }

      // 3. Jika poin 2 gagal atau formatnya bukan JSON, split berdasarkan koma ATAU baris baru
      if (finalFeatures.length === 0) {
        finalFeatures = cleaned
          .split(/[,\n]/) // Split pakai koma ATAU enter biar user gampang inputnya
          .map((f: string) => f.trim())
          .filter((f: string) => f !== '');
      }
    }

    const planPayload = {
      ...payload,
      price: Number(payload.price),
      duration_days: Number(payload.duration_days),
      features: finalFeatures, // <--- DIJAMIN ARRAY []string
      is_active: isEdit ? this.selectedPlan()?.is_active : true,
    };

    // Log ini buat Bos cek di Console F12 sebelum request dikirim
    console.log('Payload yang dikirim ke Go:', planPayload);

    const request = isEdit
      ? this.api.put(`/admin/subscriptions/plans/${id}`, planPayload)
      : this.api.post('/admin/subscriptions/plans', planPayload);

    request.subscribe({
      next: () => {
        this.showToast(`Plan ${isEdit ? 'diperbarui' : 'berhasil dibuat'}!`);
        this.showModal.set(false);
        this.loadPlans();
      },
      error: (err) => {
        this.showToast(
          err.error?.message || 'Gagal menyimpan. Cek format JSON Features!',
          'error',
        );
      },
    });
  }

  handleDelete(id: string) {
    if (!confirm('Apakah anda yakin ingin menghapus plan ini?')) return;

    this.api.delete(`/admin/subscriptions/plans/${id}`).subscribe({
      next: () => {
        this.showToast('Plan berhasil dihapus!');
        this.loadPlans();
      },
      error: () => this.showToast('Gagal menghapus plan', 'error'),
    });
  }

  toggleStatus(plan: FormattedPlan) {
    const nextStatus = !plan.is_active;
    const { parsedFeatures, ...cleanPayload } = plan;

    this.api
      .put(`/admin/subscriptions/plans/${plan.id}`, {
        ...cleanPayload,
        is_active: nextStatus,
      })
      .subscribe({
        next: () => {
          this.loadPlans();
          this.showToast(`Status ${plan.name} diperbarui`);
        },
        error: () => this.showToast('Gagal update status', 'error'),
      });
  }

  openCreateModal() {
    this.selectedPlan.set(undefined);
    this.showModal.set(true);
  }

  showToast(message: string, type: 'success' | 'error' = 'success') {
    this.toastMessage.set(message);
    this.toastType.set(type);
    setTimeout(() => this.toastMessage.set(null), 3000);
  }

  getBadgeClass(status: string) {
    return {
      'status-success': status === 'SUCCESS',
      'status-pending': status === 'PENDING',
      'status-failed': status === 'FAILED',
    };
  }
}
