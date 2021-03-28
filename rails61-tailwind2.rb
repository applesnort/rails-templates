# Rails Template which adapts David Teren's `TailwindCSS 2.0 with Rails 6.1` article
# https://davidteren.medium.com/tailwindcss-2-0-with-rails-6-1-postcss-8-0-9645e235892d

# Intended to be run with the following console command
# rails new \
#   --skip-spring \
#   -m /Users/Joel/source/rails-templates/rails61-tailwind2.rb \
#   tails-test

run 'rm -rf vendor'
run 'rails webpacker:install'

after_bundle do
  run "yarn remove @rails/webpacker"
  
  run "yarn add 'rails/webpacker#b6c2180'"
  
  run 'rails webpacker:install:react'
end

gsub_file('Gemfile', /gem\s\'webpacker',\s\'\~\>\s5.+/, 'gem "webpacker", github: "rails/webpacker", ref: \'b6c2180\'')

run "bundle"

run "yarn add tailwindcss postcss autoprefixer @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio"

run "mkdir app/javascript/stylesheets && touch app/javascript/stylesheets/application.scss"

append_file 'app/javascript/stylesheets/application.scss', <<~SCSS
  @import "tailwindcss/base";
  @import "tailwindcss/components";
  @import "tailwindcss/utilities";
SCSS

inject_into_file 'app/javascript/packs/application.js', before: 'Rails.start()' do
  <<~JS
    require("stylesheets/application.scss")

  JS
end



inject_into_file 'app/views/layouts/application.html.erb', before: '</head>' do <<~HTML
  <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
  <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
  HTML
end

run "npx tailwindcss init --full"


inject_into_file 'tailwind.config.js', after: 'sans: [' do <<~TXT
  
  'Inter var',
  TXT
end

generate(:controller, "home", "index")

append_file 'app/views/home/index.html.erb', <<~HTML
  <div class="font-sans bg-white h-screen flex flex-col w-full">
    <div class="h-screen bg-gradient-to-r from-green-400 to-blue-500">
      <div class="px-4 py-48">
      <div class="relative w-full text-center">
        <h1
        class="animate-pulse font-bold text-gray-200 text-2xl mb-6">
        Your TailwindCSS setup is working if this pulses...
        </h1>
      </div>
      </div>
    </div>
  </div>
HTML

route "root 'home#index'"

after_bundle do

  inject_into_file 'postcss.config.js', after: "plugins: [" do <<~JS
    \n\t\trequire('tailwindcss'),
    JS
  end
  
  inject_into_file 'tailwind.config.js', after: 'plugins: [' do <<~JS
    \n\t\trequire('@tailwindcss/forms'),
    \t\trequire('@tailwindcss/typography'),
    \t\trequire('@tailwindcss/aspect-ratio'),
    JS
  end
  
  gsub_file("config/puma.rb", 'port ENV.fetch("PORT") { 3000 }', 'port ENV.fetch("PORT") { 3875 }')

  run "rm -rf .browserslistrc"

end
