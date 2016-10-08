import React from "react";

import Button from "../core/Button";

const ICalledButton = ({bankName, onClick}) => {
  return (
    <Button
      onClick={onClick}
      primary
      small
    >
      I called {bankName}
    </Button>
  );
};

module.exports = ICalledButton;
