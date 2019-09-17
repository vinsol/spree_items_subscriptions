module Spree::OrderDecorator
  def self.prepended(base)
    base.has_one :order_subscription, class_name: "Spree::OrderSubscription", dependent: :destroy
    base.has_one :parent_subscription, through: :order_subscription, source: :subscription
    base.has_many :subscriptions, class_name: "Spree::Subscription",
                           foreign_key: :parent_order_id,
                           dependent: :restrict_with_error

    base.after_update :update_subscriptions

    base.state_machine.after_transition to: :complete, do: :enable_subscriptions, if: :any_disabled_subscription?
  end

  def available_payment_methods
    if subscriptions.exists?
      @available_payment_methods = Spree::Gateway.active.available_on_front_end
    else
      @available_payment_methods ||= Spree::PaymentMethod.active.available_on_front_end
    end
  end

  def all_shipments_has_label?
    shipments.all? { |shipment| shipment.labels.any? }
  end

  def all_shipments_label_status_is?(label_status)
<<<<<<< HEAD
    shipments.all? { |shipment| shipment.labels.all? { |label| label.status == label_status } }
=======
    shipments.all? { |shipment| shipment.labels.all? { |label| label.state == label_status } }
>>>>>>> fd0af0d... Create LabelStatusSubscription
  end

  private

    def enable_subscriptions
      subscriptions.each do |subscription|
        subscription.update(
          source: payments.from_credit_card.first.source,
          enabled: true,
          ship_address: ship_address.clone,
          bill_address: bill_address.clone
        )
      end
    end

    def any_disabled_subscription?
      subscriptions.disabled.any?
    end

    def update_subscriptions
      line_items.each do |line_item|
        if line_item.subscription_attributes_present?
          subscriptions.find_by(variant: line_item.variant).update(line_item.updatable_subscription_attributes)
        end
      end
    end

end

::Spree::Order.prepend(Spree::OrderDecorator)
