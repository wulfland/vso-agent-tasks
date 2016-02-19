/// <reference path="../../definitions/vsts-task-lib.d.ts" />

import tl = require('vsts-task-lib/task');

var codeCoverageTool = tl.getInput('codeCoverageTool', true);
var summaryFileLocation = tl.getInput('summaryFileLocation', true);
var reportDirectory = tl.getInput('reportDirectory');
var additionalCodeCoverageFiles = tl.getInput('additionalCodeCoverageFiles');

tl.debug('codeCoverageTool: ' + codeCoverageTool);
tl.debug('summaryFileLocation: ' + summaryFileLocation);
tl.debug('reportDirectory: ' + reportDirectory);
tl.debug('additionalCodeCoverageFiles: ' + additionalCodeCoverageFiles);

//check for pattern in testResultsFiles
if(additionalCodeCoverageFiles.indexOf('*') >= 0 || additionalCodeCoverageFiles.indexOf('?') >= 0) {
  tl.debug('Pattern found in additionalCodeCoverageFiles parameter');
  var buildFolder = tl.getVariable('agent.buildDirectory');
  var allFiles = tl.find(buildFolder);
  var codeCoverageFiles = tl.match(allFiles, additionalCodeCoverageFiles, { matchBase: true });
}
else {
  tl.debug('No pattern found in additionalCodeCoverageFiles parameter');
  var codeCoverageFiles = [additionalCodeCoverageFiles];
}

var tp = new tl.CodeCoveragePublisher();
tp.publish(codeCoverageTool, summaryFileLocation, reportDirectory, codeCoverageFiles);