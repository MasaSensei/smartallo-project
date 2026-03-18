import { Component, OnInit, inject, signal } from '@angular/core';
import { ApiService } from '../../core/services/api.service';
import { CommonModule, DecimalPipe } from '@angular/common';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, DecimalPipe],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  // 1. Inject ApiService buatanmu sendiri
  private api = inject(ApiService);

  stats = signal<any>(null);
  isLoading = signal<boolean>(true);
  toastMessage = signal<string | null>(null);
  toastType = signal<'success' | 'error'>('error');

  ngOnInit() {
    this.fetchSystemIntelligence();
  }

  showToast(message: string, type: 'success' | 'error' = 'error') {
    this.toastMessage.set(message);
    this.toastType.set(type);
    // Hilangkan toast setelah 3 detik
    setTimeout(() => this.toastMessage.set(null), 3000);
  }

  fetchSystemIntelligence() {
    // 2. Sekarang panggil via this.api, path-nya jadi lebih bersih
    this.api.get<any>('/dashboard/owner/intelligence').subscribe({
      next: (data) => {
        this.stats.set(data);
        this.isLoading.set(false);
      },
      error: (err) => {
        console.error('Sultan Error:', err);
        this.isLoading.set(false);
        this.showToast('Gagal memuat data', 'error');
      },
    });
  }
}
