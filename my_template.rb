run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

inject_into_file 'Gemfile', before: 'group :development, :test do' do
  <<~RUBY
    gem 'autoprefixer-rails'
    gem 'simple_form'
    gem 'simple_form-tailwind'
  RUBY
end

inject_into_file 'Gemfile', after: 'group :development, :test do' do
  <<~RUBY

  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'dotenv-rails'
  RUBY
end

after_bundle do
  rails_command 'db:drop db:create db:migrate'
  generate(:controller, 'pages', 'home', '--skip-routes', '--no-test-framework')
  
  route "root to: 'pages#home'"

  # Git ignore
  ########################################
  append_file '.gitignore', <<~TXT
  
    # Ignore .env file containing credentials.
    .env*

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT






  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
