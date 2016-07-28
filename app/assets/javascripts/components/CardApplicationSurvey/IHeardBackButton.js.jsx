const React = require("react");

const Button = require("../core/Button");

const IHeardBackButton = ({bankName, onClick}) => {
  let text;
  if (bankName) {
    text = `I heard back from ${bankName} by mail or email`;
  } else {
    text = "I heard back from the bank";
  }

  const primary = typeof bankName === "undefined";

  return (
    <Button
      default={!primary}
      onClick={onClick}
      primary={primary}
      small
    >
      {text}
    </Button>
  );
};

module.exports = IHeardBackButton;

