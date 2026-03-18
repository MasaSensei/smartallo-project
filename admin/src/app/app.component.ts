import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet], // Wajib ada ini
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {}
