_done = QUnit.done;
if(QUnit.urlParams.resultsURL){
  QUnit.done = function(result){
    $.get(QUnit.urlParams.resultsURL, {
      total: result.total,
      passed: result.passed,
      failed: result.failed
    });
    _done(arguments[0]);
  }
}
