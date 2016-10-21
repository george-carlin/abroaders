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
        credit cards that can earn you points.  You generally need to be either
        a U.S. citizen or a permanent resident to be approved for cards issued by U.S. Banks.
      </p>

      <p>
        Banks in the U.S. give away thousands of dollars worth of reward points
        when you open a new credit card account. If you can open a credit card
        in the United States should choose “Yes - I am eligible” even if you
        aren’t ready to apply for a new card right away. We’ll ask about when
        you’re ready to apply for cards later in the survey.
      </p>
    </div>
  );
};

export default HelpText;
