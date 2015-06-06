class LinkedinMailer < ApplicationMailer
  def export(result, email, template)
    xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "/linkedin_mailer/#{template}", layout: false, locals: { result: result }
    attachments["#{template}.xlsx"] = { mime_type: Mime::XLSX, content: xlsx }

    mail(to: email, subject: '[Relatório Linkedin] Extração Completa')
  end
end
