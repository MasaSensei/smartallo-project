import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { SubscriptionPlan } from '../../../../core/models/subscription.model';

@Component({
  selector: 'app-subscription-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './subscription-form.component.html',
  styleUrls: ['./subscription-form.component.scss'],
})
export class SubscriptionFormComponent implements OnInit {
  @Input() planData?: SubscriptionPlan; // Kalau ada, berarti mode EDIT
  @Output() close = new EventEmitter<void>();
  @Output() save = new EventEmitter<any>();

  planForm!: FormGroup;

  constructor(private fb: FormBuilder) {}

  ngOnInit() {
    this.planForm = this.fb.group({
      name: [this.planData?.name || '', Validators.required],
      tier: [this.planData?.tier || 'FREE', Validators.required],
      price: [
        this.planData?.price || 0,
        [Validators.required, Validators.min(0)],
      ],
      duration_days: [this.planData?.duration_days || 30, Validators.required],
      features: [
        this.planData ? JSON.stringify(this.planData.features) : '[]',
        Validators.required,
      ],
    });
  }

  onSubmit() {
    if (this.planForm.valid) {
      const val = this.planForm.value;
      // Convert string kembali ke JSON object untuk dikirim ke Go
      try {
        val.features = JSON.parse(val.features);
        this.save.emit(val);
      } catch (e) {
        alert(
          'Format Features harus JSON array! Contoh: ["Fitur 1", "Fitur 2"]',
        );
      }
    }
  }
}
