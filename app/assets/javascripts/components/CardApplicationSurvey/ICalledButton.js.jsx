const React = require("react");

const Button = require("../core/Button");

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
