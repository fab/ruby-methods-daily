require 'nokogiri'
require 'open-uri'
require 'gibbon'

def docs_url(classname, method_link = '')
  "http://www.ruby-doc.org/core-1.9.3/#{classname}.html" + "#{method_link}"
end

def random_class
  ['Array', 'Enumerable', 'Hash', 'Numeric', 'Object', 'String'].sample
end

def random_method(classname)
  doc = Nokogiri::HTML(open(docs_url(classname)))
  method_list = doc.css('.link-list').first.children.css('li')
  list_length = method_list.count
  method = method_list[rand(list_length + 1)]
  method_name = method.text
  method_link = method.children[0].values[0]
  node = doc.xpath(find_by_xpath(method_link))
  method_div = node[0].parent
  method_div.css('.method-source-code, .method-click-advice').remove # remove the source code toggle
  [classname, method_name, method_link, method_div]
end

def find_by_xpath(method_link)
  "//a[@name='#{method_link[1..-1]}']"
end

def method_html(method_array)
  "<div class='method-info'>
    <h2 class='method-name'>#{method_array[0]}#{method_array[1]}</h2>
    #{method_array[3].to_html}
  </div>
  <p class='link'>Click <a href='#{docs_url(method_array[0], method_array[2])}'>here</a> to view this method on the Ruby Docs</p>"
end

def style_tag
  '<style>
    h1 {
      margin-top: 0;
      margin-bottom: 10px;
      text-align: center;
    }
    h2.method-name {
      margin: 0;
      margin-left: 5px;
      float: left;
    }
    h2.date {
      margin: 0;
      margin-right: 5px;
      float: right;
    }
    p.tagline, p.link {
      min-width: 600px;
      margin-top: 0;
      text-align: center;
    }
    p.link {
      margin-bottom: 30px;
    }
    .header {
      width: 600px;
      margin: 0 auto;
      padding: 0.5em;
      color: #c60000;
    }
    .method-info {
      width: 600px;
      margin: 0 auto;
      margin-bottom: 10px;
    }
    .method-name-and-date {
      margin-bottom: 10px;
      height: 30px;
      line-height: 30px;
    }
    .method-detail {
      max-width: 600px;
      padding: 0.5em;
      background-color: #eee;
      clear: both;
    }
    .method-heading {
      font-size: 125%;
      font-weight: bold;
    }
    .footer {
      min-width: 600px;
      text-align: center;
      font-size: 12px;
    }
    .mailchimp-logo {
      margin: 0 auto;
      margin-top: 10px;
    }
    .ruby {
      padding: 0.5em;
      background: #303030;
      color: #fff;
    }
    .ruby-constant   { color: #7fffd4; }
    .ruby-keyword    { color: #00ffff; }
    .ruby-ivar       { color: #eedd82; }
    .ruby-operator   { color: #00ffee; }
    .ruby-identifier { color: #ffdead; }
    .ruby-node       { color: #ffa07a; }
    .ruby-regexp     { color: #ffa07a; }
    .ruby-value      { color: #7fffd4; }
    .ruby-comment    { color: #5eff1f; font-weight: bold; }
  </style>'
end

def header
  "<div class='header'>
    <h1>Ruby Methods Daily</h1>
    <p class='tagline'>Different Ruby methods in your inbox each day</p>
  </div>"
end

def footer
  "<div class='footer'>
    <p>Ruby Methods Daily is a service put together by <a href='https://github.com/fab'>Fab Mackojc</a></p>
    <p>Credit to <a href='http://www.neurogami.com'>Neurogami</a> for rubydoc formatting</p>
    <a href='*|LIST:SUBSCRIBE|*'>Subscribe to this list</a> | <a href='*|UPDATE_PROFILE|*'>Update your subscription preferences</a> | <a href='*|UNSUB|*'>Unsubscribe from this list</a>
    <div class='mailchimp-logo'>*|REWARDS|*</div>
  </div>"
end

def generate_email_html
  "<html>
    <head><meta http-equiv='Content-Type' content='text/html;charset=utf-8'/>#{style_tag}</head>
    <body>
      #{header}
      #{method_html(random_method(random_class))}
      #{method_html(random_method(random_class))}
      #{method_html(random_method(random_class))}
      #{footer}
    </body>
  </html>"
end

def create_mailchimp_campaign(html)
  @gb = Gibbon.new
  @gb.campaignCreate({:type => 'regular',
                     :options => {:list_id => '28baf018f9',
                                  :subject => "Ruby Methods Daily - #{Time.now.strftime('%b %d')}",
                                  :from_email => 'fab.mackojc@gmail.com',
                                  :from_name => 'Ruby Methods Daily',
                                  :to_name => '*|FNAME|*',
                                  :authenticate => true,
                                  :inline_css => true,
                                  :generate_text => true},
                     :content => {:html => html}})
end

def send_mailchimp_campaign(cid)
  @gb.campaignSendNow({:cid => cid})
end

def create_and_send_email
  html = generate_email_html
  cid = create_mailchimp_campaign(html)
  send_mailchimp_campaign(cid)
end
