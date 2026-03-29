import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ApiService } from '../../../core/services/api.service';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private api = inject(ApiService);
  private router = inject(Router);

  // State Management dengan Signals (Angular 17/18+)
  showPassword = signal(false);
  isLoading = signal(false);
  toastMessage = signal<string | null>(null);
  toastType = signal<'success' | 'error'>('error');

  loginForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]],
  });

  togglePassword() {
    this.showPassword.update((v) => !v);
  }

  showToast(message: string, type: 'success' | 'error' = 'error') {
    this.toastMessage.set(message);
    this.toastType.set(type);
    // Hilangkan toast setelah 3 detik
    setTimeout(() => this.toastMessage.set(null), 3000);
  }

  onSubmit() {
    if (this.loginForm.valid) {
      this.isLoading.set(true);

      // Tambahkan interface response biar rapi
      interface LoginResponse {
        data: {
          token: string;
        };
        message?: string;
      }

      this.api
        .post<LoginResponse>('/auth/login', this.loginForm.value) // Pakai interface tadi
        .subscribe({
          next: (res) => {
            // Sekarang res.data.token valid di mata TypeScript
            const token = res?.data?.token;

            if (token) {
              localStorage.setItem('token', token);
              this.showToast('Login Berhasil!', 'success');
              setTimeout(() => this.router.navigate(['/dashboard']), 1000);
            }
          },
          error: (err) => {
            this.isLoading.set(false);
            const msg = err.error?.message || 'Email atau Password salah';
            this.showToast(msg, 'error');
          },
        });
    }
  }
}
