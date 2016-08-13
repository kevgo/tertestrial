require! {
  'chai' : {expect}
  'path'
  'wait' : {wait, wait-until}
}


module.exports = ->

  @Given /^a file "([^"]*)" with the content:$/ (file-name, content) ->
    @create-file file-name, content


  @Given /^Tertestrial is running inside the "([^"]*)" example application$/, timeout: 20_000, (app-name, done) ->
    @root-dir = path.join 'example-applications', app-name
    @run-process 'npm i'
    @start-process '../../bin/tertestrial', done


  @Given /^Tertestrial runs with the configuration:$/, timeout: 20_000, (config, done) ->
    @root-dir = 'tmp'
    @create-file 'tertestrial.yml', config
    @start-process '../bin/tertestrial', done


  @Given /^Tertestrial runs with the configuration file "([^"]*)":$/ (filename, content, done) ->
    @root-dir = 'tmp'
    @create-file filename, content
    @start-process '../bin/tertestrial', done


  @When /^entering '\[ENTER\]'$/ ->
    @process.stdin.write "\n"


  @When /^trying to start tertestrial$/ (done) ->
    @root-dir = 'tmp'
    @start-process '../bin/tertestrial', (err) ->
      expect(err).to.exist
      done!


  @When /^starting 'tertestrial setup'$/ ->
    @root-dir = 'tmp'
    @process = @start-process '../bin/tertestrial setup'


  @When /^sending the command:$/ (command, done) ->
    @send-command command, done


  @When /^sending filename "([^"]*)" and line "([^"]*)"$/ (filename, line, done) ->
    data = {filename}
    data.line = line if line
    @send-command JSON.stringify(data), done


  @Then /^I see "([^"]*)"$/ (expected-text, done) ->
    @process.wait expected-text, done


  @Then /^I see:$/ (expected-text, done) ->
    @process.wait expected-text, done


  @Then /^it creates a file "([^"]*)"$/ (filename) ->
    @file-exists filename


  @Then /^the process ends$/ (done) ->
    wait-until (~> @process.ended), done


  @Then /^the process is still running$/ (done) ->
    # Note: if the process doesn't crash within 100ms, we consider it remains running
    wait 100, ~>
      expect(@process.ended).to.be.false
      done!
