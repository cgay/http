Module: dsp-test-suite
Author: Carl Gay
Synopsis: Tests for the Dylan Server Pages library.
Copyright: See LICENSE in this distribution for details.

// Just make sure template-engine is basically working.
define test test-template-engine ()
  let markup = "{{repeat with x in words}}{{x}} {{end}}";
  let template = make(<template>, document: markup);
  let words = #["one", "two", "three"];
  let output = process-template(template, variables: template-vocabulary(template, words));
  assert-equal(output, "one two three ");
end test test-template-engine;
