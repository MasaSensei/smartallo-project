import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BillingControlComponent } from './billing-control.component';

describe('BillingControlComponent', () => {
  let component: BillingControlComponent;
  let fixture: ComponentFixture<BillingControlComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BillingControlComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BillingControlComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
