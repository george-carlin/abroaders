import { PropTypes } from "react";

// Shared logic for input components like <RadioButton>, <TextField>,
// <NumberField> - i.e. components that wrap a 'basic' input field and give it
// a Railsy `name` and `id` field.
export default {
  propTypes: {
    attribute: PropTypes.string.isRequired,
    modelName: PropTypes.string.isRequired,
  },

  getId({modelName, attribute}) {
    return `${modelName}_${attribute}`;
  },

  getName({modelName, attribute}) {
    return `${modelName}[${attribute}]`;
  },

  getProps(originalProps, additionalProps) {
    return Object.assign(
      {},
      originalProps,
      {
        id:   this.getId(originalProps),
        name: this.getName(originalProps),
      },
      additionalProps
    );
  },
};
