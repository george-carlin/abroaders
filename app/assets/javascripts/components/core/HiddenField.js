import { createElement, PropTypes } from "react";

import HTMLInput    from "./shared/HTMLInput";

// Extend <input type="hidden" with Rails-style attributes:
//
//  <HiddenField modelName="person" attribute="id" />
//  // =
//  <input
//    type="hidden"
//    id="person_id"
//    name="person[id]"
//  />
//
// Note that we haven't bothered creating a <HiddenFieldTag> component
// (analogous to <TextFieldTag> or <NumberFieldTag> because all '*FieldTag'
// classes do at the moment is add some Bootstrap CSS classes to the plain HTML
// tag. Since hidden fields are hidden (duh), they don't need any Bootstrap CSS
// classes, so there's no need wrapping them in another component.
const HiddenField = (props) => {
  return createElement("input", HTMLInput.getProps(props, { type: "hidden" }));
};

HiddenField.propTypes = Object.assign({}, HTMLInput.propTypes);

export default HiddenField;
