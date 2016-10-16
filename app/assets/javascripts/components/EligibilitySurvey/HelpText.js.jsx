import React from "react";

const HelpText = ({hasCompanion}) => {
  let firstParaText;
  if (hasCompanion) {
    firstParaText = "Are you and your partner eligible to apply for credit " +
                    "cards issued by banks in the United States?";
  } else {
    firstParaText = "Are you eligible to apply for credit cards issued by " +
                    "banks in the United States?";
  }

  return (
    <div>
      <p>{firstParaText}</p>

      <p>
        We ask this to confirm that you're eligible to get approved for U.S.
        credit cards that can earn you points.
      </p>

      <p>
        You generally need to be either a U.S. citizen or a permanent
        resident to be approved for cards issued by U.S. Banks.
      </p>
    </div>
  );
};

export default HelpText;
