import React, { PropTypes } from "react";

import Alert from "../core/Alert";

const ErrorMessages = ({messages}) =>
  <Alert danger dismissable >
    There
    {messages.length === 1 ? ' was an error:' : ` were ${messages.length} errors:`}

    <ul>{messages.map((message, i) => <li key={i}>{message}</li>)}</ul>
  </Alert>;

export default ErrorMessages;
