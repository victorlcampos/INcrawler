class PaymentsController < ApplicationController
  def create
    @payment = Payment.new(params.require(:payment).permit(:justify, :value))
    @payment.value *= 100
    @payment.save!

    redirect_to root_path, notice: 'Obrigado! Ainda não temos um meio de pagamento, mas ficamos felizes em saber seu feedback'
  end
end
