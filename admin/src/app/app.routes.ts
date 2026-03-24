import { Routes } from '@angular/router';
import { LoginComponent } from './features/auth/login/login.component';
import { MainLayoutComponent } from './layouts/main-layout/main-layout.component';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then(
            (m) => m.DashboardComponent,
          ),
      },
      {
        path: 'billing-control',
        loadComponent: () =>
          import('./features/billing-control/billing-control.component').then(
            (m) => m.BillingControlComponent,
          ),
      },
      //   {
      //     path: 'pockets',
      //     loadComponent: () =>
      //       import('./features/pockets/pockets.component').then(
      //         (m) => m.PocketsComponent,
      //       ),
      //   },
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
    ],
  },

  // Fallback
  { path: '**', redirectTo: 'login' },
];
