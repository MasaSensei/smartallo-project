import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  RouterOutlet,
  RouterLink,
  RouterLinkActive,
  Router,
} from '@angular/router';

interface MenuItem {
  path: string;
  icon: string;
  label: string;
}

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './main-layout.component.html',
  styleUrl: './main-layout.component.scss',
})
export class MainLayoutComponent {
  private router = inject(Router);

  menuItems: MenuItem[] = [
    { path: '/dashboard', icon: 'analytics', label: 'System Intel' }, // Liat total perputaran uang global

    // --- CORE DATA ---
    { path: '/organizations', icon: 'corporate_fare', label: 'Books/Entities' }, // Daftar "Buku Tabungan" yang terdaftar
    {
      path: '/user-management',
      icon: 'manage_accounts',
      label: 'Account Holders',
    },

    // --- REVENUE ---
    { path: '/billing-control', icon: 'payments', label: 'Plans & Quotas' }, // Atur harga langganan & limit catat

    // --- RELIABILITY ---
    { path: '/system-logs', icon: 'terminal', label: 'Audit Trail' }, // Siapa catat apa, biar nggak ada manipulasi
    { path: '/settings', icon: 'tune', label: 'App Config' }, // Ganti bunga (kalau ada), maintenance, dll
  ];

  onLogout() {
    localStorage.removeItem('token');
    this.router.navigate(['/login']);
  }
}
