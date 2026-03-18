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

      this.api
        .post<{ token: string }>('/auth/login', this.loginForm.value)
        .subscribe({
          next: (res) => {
            localStorage.setItem('token', res.token);
            this.showToast('Login Berhasil! Mengalihkan...', 'success');

            setTimeout(() => {
              this.router.navigate(['/dashboard']);
            }, 1000);
          },
          error: (err) => {
            this.isLoading.set(false);
            // Ambil pesan error dari backend Go atau default
            const msg = err.error?.error || 'Email atau Password salah';
            this.showToast(msg, 'error');
          },
        });
    }
  }
}
