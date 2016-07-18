namespace :rubo do
  desc 'Generate and display Rubocop HTML report.'
  task :html do
    `rubocop -f html -D --out rubocop/report.html`
  end

  desc 'Autofix Issues.'
  task :fix do
    `rubocop -a`
    Rake::Task['rubo:html'].execute
  end

  desc 'AutoFix issues and display report.'
  task :fix_report do
    Rake::Task['rubo:fix'].execute
    Rake::Task['rubo:gen_report'].execute
  end

  desc 'Regenerate To Do .yml'
  task :autogen do
    `rubocop --auto-gen-config`
  end

  desc 'Show rubocop HTML report'
  task :gen_report do
    `open rubocop/report.html`
  end

  desc 'Show rubocop HTML report'
  task :report do
    Rake::Task['rubo:html'].execute
    Rake::Task['rubo:gen_report'].execute
  end
end

task rubo: ['rubo:fix_report']
