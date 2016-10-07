import React, { PropTypes } from "react";

import HTMLInput from "./shared/HTMLInput";

// Extend TextFieldTag with Rails-style attributes:
//
//  <TextField modelName="person" attribute="name" />
//  // =
//  <TextFieldTag
//    id="person_name"
//    name="person[name]"
//  />
const TextFieldTag = require("./TextFieldTag");

const TextField = (props) => {
  return <TextFieldTag {...HTMLInput.getProps(props)} />;
};

TextField.propTypes = Object.assign(
  {},
  TextFieldTag.propTypes,
  HTMLInput.propTypes
);

module.exports = TextField;
