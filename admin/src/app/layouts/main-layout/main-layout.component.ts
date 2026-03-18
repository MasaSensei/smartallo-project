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
    { path: '/dashboard', icon: 'analytics', label: 'System Intel' },
    { path: '/organizations', icon: 'corporate_fare', label: 'Organizations' },
    {
      path: '/user-management',
      icon: 'manage_accounts',
      label: 'User Control',
    },

    // --- MENU BARU ---
    { path: '/billing-control', icon: 'payments', label: 'Billing & Plans' },
    // -----------------

    { path: '/system-logs', icon: 'terminal', label: 'System Logs' },
    { path: '/settings', icon: 'tune', label: 'System Config' },
  ];
  onLogout() {
    localStorage.removeItem('token');
    this.router.navigate(['/login']);
  }
}
