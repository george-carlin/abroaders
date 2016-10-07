import { PropTypes } from "react";
import classnames from "classnames";

// Shared logic for input components like <TextFieldTag>, <NumberFieldTag> -
// i.e. components that return a form input tag with some Bootstrap HTML
// classes.
export default {
  propTypes: {
    className: PropTypes.string,
    small:      PropTypes.bool,
  },

  getProps(originalProps) {
    return Object.assign(
      {},
      originalProps,
      {
        className: classnames([
          originalProps.className,
          {
            "form-control": true,
            "input-sm":     originalProps.small,
          },
        ]),
      }
    );
  },
};
