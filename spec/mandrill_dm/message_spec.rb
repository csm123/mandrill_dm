require 'spec_helper'

describe MandrillDm::Message do
  def mail(options={}, &blk)
    Mail.new(options, &blk)
  end

  describe '#from_email' do
    it 'takes a single email' do
      mail = mail(from: 'from_name@domain.tld')
      message = described_class.new(mail)
      expect(message.from_email).to eq('from_name@domain.tld')
    end

    it 'takes a single email with a display name' do
      mail = mail(from: 'John Doe <from_name@domain.tld>')
      message = described_class.new(mail)
      expect(message.from_email).to eq('from_name@domain.tld')
    end
  end

  describe '#from_name' do
    it 'takes a single email' do
      mail = mail(from: 'from_name@domain.tld')
      message = described_class.new(mail)
      expect(message.from_name).to eq(nil)
    end

    it 'takes a single email with a display name' do
      mail = mail(from: 'John Doe <from_name@domain.tld>')
      message = described_class.new(mail)
      expect(message.from_name).to eq('John Doe')
    end
  end

  describe '#html' do
    it 'takes a non-multipart message' do
      mail = mail(to: 'name@domain.tld', body: '<html><body>Hello world!</body></html>')
      message = described_class.new(mail)
      expect(message.html).to eq('<html><body>Hello world!</body></html>')
    end

    it 'takes a multipart message' do
      html_part = Mail::Part.new do
        content_type 'text/html'
        body '<html><body>Hello world!</body></html>'
      end

      text_part = Mail::Part.new do
        content_type 'text/plain'
        body 'Hello world!'
      end

      mail = mail(to: 'name@domain.tld', content_type: 'multipart/alternative') do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      message = described_class.new(mail)
      expect(message.html).to eq('<html><body>Hello world!</body></html>')
    end
  end

  describe '#text' do
    it 'does not take a non-multipart message' do
      mail = mail(to: 'name@domain.tld', body: 'Hello world!')
      message = described_class.new(mail)
      expect(message.text).to eq(nil)
    end

    it 'takes a multipart message' do
      html_part = Mail::Part.new do
        content_type 'text/html'
        body '<html><body>Hello world!</body></html>'
      end

      text_part = Mail::Part.new do
        content_type 'text/plain'
        body 'Hello world!'
      end

      mail = mail(to: 'name@domain.tld', content_type: 'multipart/alternative') do |p|
        p.html_part = html_part
        p.text_part = text_part
      end
      message = described_class.new(mail)
      expect(message.text).to eq('Hello world!')
    end
  end

  describe '#to' do
    it 'takes a single email' do
      mail = mail(to: 'name@domain.tld')
      message = described_class.new(mail)
      expect(message.to).to eq([{email: 'name@domain.tld', name: nil, type: 'to'}])
    end

    it 'takes a single email with a display name' do
      mail = mail(to: 'John Doe <name@domain.tld>')
      message = described_class.new(mail)
      expect(message.to).to eq([{email: 'name@domain.tld', name: 'John Doe', type: 'to'}])
    end

    it 'takes an array of emails' do
      mail = mail(to: ['name1@domain.tld', 'name2@domain.tld'])
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          {email: 'name1@domain.tld', name: nil, type: 'to'},
          {email: 'name2@domain.tld', name: nil, type: 'to'}
        ]
      )
    end

    it 'takes an array of emails with a display names' do
      mail = mail(to: ['John Doe <name1@domain.tld>', 'Jane Smith <name2@domain.tld>'])
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          {email: 'name1@domain.tld', name: 'John Doe', type: 'to'},
          {email: 'name2@domain.tld', name: 'Jane Smith', type: 'to'}
        ]
      )
    end

    it 'combines to, cc, and bcc fields' do
      mail = mail(to: 'John Doe <name1@domain.tld>', cc: 'Jane Smith <name2@domain.tld>', bcc: 'Jenny Craig <name3@domain.tld>')
      message = described_class.new(mail)
      expect(message.to).to eq(
        [
          {email: 'name1@domain.tld', name: 'John Doe', type: 'to'},
          {email: 'name2@domain.tld', name: 'Jane Smith', type: 'cc'},
          {email: 'name3@domain.tld', name: 'Jenny Craig', type: 'bcc'}
        ]
      )
    end
  end

  describe '#subject' do
    it 'takes a subject' do
      mail = mail(subject: 'Test Subject')
      message = described_class.new(mail)
      expect(message.subject).to eq('Test Subject')
    end
  end

  pending '#headers'
  pending '#important'
  pending '#track_opens'
  pending '#track_clicks'
  pending '#auto_text'
  pending '#auto_html'
  pending '#inline_css'
  pending '#url_strip_qs'
  pending '#preserve_recipients'
  pending '#view_content_link'

  describe  '#bcc_address' do
    it 'takes a bcc_address' do
      mail = mail(bcc_address: 'bart@simpsons.com')
      message = described_class.new(mail)
      expect(message.bcc_address).to eq('bart@simpsons.com')
    end
  end

  pending '#tracking_domain'
  pending '#signing_domain'
  pending '#return_path_domain'
  pending '#merge'

  # describe '#global_merge_vars' do
  #   pending
  #   it 'takes global merge vars' do
  #     merge_vars = [{"name"=>"var1", "content"=>"Global Value 1"}, {"name"=>"var2", "content"=>"Global Value 2"}]
  #     mail = mail(:global_merge_vars => merge_vars)
  #     message = described_class.new(mail)
  #     expect(message.global_merge_vars.to).to eq merge_vars
  #   end
  # end

  pending '#merge_vars'
  pending '#tags'

  describe '#subaccount' do
    it 'takes a subaccount' do
      mail = mail(subaccount: 'abc123')
      message = described_class.new(mail)
      expect(message.subaccount).to eq('abc123')
    end
  end

  pending '#google_analytics_domains'
  pending '#google_analytics_campaign'
  pending '#metadata'
  pending '#recipient_metadata'
  pending '#attachments'
  pending '#images'

  describe "#to_json" do
    it "returns a proper JSON response for the Mandrill API" do
      mail = mail(body: 'test', from: 'name@domain.tld', global_merge_vars: [{"name"=>"var1", "content"=>"Global Value 1"}, {"name"=>"var2", "content"=>"Global Value 2"}])
      message = described_class.new(mail)
      expect(message.to_json).to include(:from_email, :from_name, :html, :subject, :to, :global_merge_vars)
    end
  end
end
