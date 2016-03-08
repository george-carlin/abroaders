jest.dontMock("../CardRecommendationActions.js.jsx");
jest.dontMock("../../CardDeclineForm");
jest.dontMock("../../CardDeclineActions");
jest.dontMock("../../Button");

const CardRecommendationActions = 
  require("../CardRecommendationActions.js.jsx");

const CardAccountStatuses = ["unknown", "recommended", "declined", "applied", "denied", "open", "closed"];

describe("CardRecommendationActions", () => {
  const React     = require("react/addons");
  const ReactDOM  = require("react-dom");
  const TestUtils = React.addons.TestUtils;

  var actions, defaultProps;

  beforeEach(() => {
    defaultProps = {
      accountId:   1,
      applyPath:   "/",
      declinePath: "/",
      status:      "recommended",
    }
  });

  const renderActions = (props) => {
    if (!props) props = defaultProps;

    actions = ReactDOM.findDOMNode(
      TestUtils.renderIntoDocument(
        React.createElement(CardRecommendationActions, props)
      )
    );
  };

  const getApplyBtn = () => {
    return actions.querySelector(".CardApplyBtn");
  };
  const getCancelBtn = () => {
    return actions.querySelector(".card_account_cancel_decline_btn");
  };
  const getConfirmBtn = () => {
    return actions.querySelector(".card_account_confirm_decline_btn");
  };
  const getDeclineBtn = () => {
    return actions.querySelector(".card_account_decline_btn");
  };

  describe("when 'status' is 'recommended'", () => {
    it("shows 'Apply' and 'No Thanks' buttons", () => {
      renderActions();
      expect(getApplyBtn()).toBeDefined()
      expect(getDeclineBtn()).toBeDefined()
      expect(getCancelBtn()).toBeNull()
      expect(getConfirmBtn()).toBeNull()
    });

    describe("clicking 'No Thanks'", () => {
      beforeEach(() => {
        renderActions();
        TestUtils.Simulate.click(getDeclineBtn());
      });

      it("shows 'cancel' and 'confirm' buttons", () => {
        expect(getCancelBtn()).toBeDefined()
        expect(getConfirmBtn()).toBeDefined()
      });

      describe("clicking 'confirm' without typing a message", () => {
        beforeEach(() => TestUtils.Simulate.click(getConfirmBtn()));

        it("shows an error message", () => {
          expect(
            actions.querySelector(
              ".decline_card_recommendation_error_message"
            )
          ).toBeDefined();
        });
      });
    });
  });

});
