class LoanNotifier < ActionMailer::Base
  def request_notification(loan)
    setup_email(loan.item.owner)
    @from = "{loan.borrower.email}"
    @subject    += 'Loan Request'
    @owner = "#{loan.item.owner.login}"
    @borrower = "#{loan.borrower.login}"
    @title = "#{loan.item.title}"
    @author = "#{loan.item.author_first} #{loan.item.author_last}"
    @body[:url]  = "http://localhost:3000/#{loan.item.type.downcase}/#{loan.item.id}"
    @body[:url2]  = "http://localhost:3000/loans"
  end

  def approved_notification(loan)
    setup_email(loan.borrower)
    @subject    += 'Loan Approved'
    @owner = "#{loan.item.owner.login}"
    @from = "#{loan.item.owner.email}"
    @title = "#{loan.item.title}"
    @author = "#{loan.item.author_first} #{loan.item.author_last}"
    @body[:url]  = "http://localhost:3000/#{loan.item.type.downcase}/#{loan.item.id}"
    @body[:url2]  = "http://localhost:3000/loans"
  end

  def rejected_notification(loan)
    setup_email(loan.borrower)
    @subject    += 'Loan Not Approved'
    @from = "#{loan.item.owner.email}"
    @title = "#{loan.item.title}"
    @author = "#{loan.item.author_first} #{loan.item.author_last}"
    @body[:url]  = "http://localhost:3000/#{loan.item.type.downcase}/#{loan.item.id}"
    @body[:url2]  = "http://localhost:3000/loans"
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = "admin@freelibrary.ca"
    @subject     = "[Free Library] "
    @sent_on     = Time.now
    @body[:user] = user
  end
end
