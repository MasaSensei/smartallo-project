export interface SubscriptionPlan {
  id: string;
  name: string;
  tier: 'FREE' | 'PRO' | 'UMKM';
  price: number;
  duration_days: number;
  features: any; // Karena []byte JSONB, di TS kita terima sebagai object/any
  is_active: boolean;
  created_at: Date;
}

export interface SubscriptionTransaction {
  id: string;
  user_id: string;
  plan_id: string;
  amount: number;
  status: 'PENDING' | 'SUCCESS' | 'FAILED';
  payment_gateway: string;
  external_id: string;
  paid_at?: Date;
  created_at: Date;
}
