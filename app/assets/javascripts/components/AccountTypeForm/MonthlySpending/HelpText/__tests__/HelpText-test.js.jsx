const path = "../../HelpText.js.jsx";
const helpBlockPath = "../../../../core/HelpBlock";

jest.unmock(path);
jest.unmock(helpBlockPath);

const React     = require('react');
const ReactDOM  = require('react-dom');
const TestUtils = require('react-addons-test-utils');
const _         = require('underscore');

const HelpBlock = require(helpBlockPath);
const HelpText  = require(path);

describe('HelpText', () => {
  const getHelpBlocks = (props) => {
    return TestUtils.scryRenderedComponentsWithType(
      TestUtils.renderIntoDocument(<HelpText {...props} />),
      HelpBlock
    );
  };

  describe("for the solo plan", () => {
    describe("when the person is ineligible", () => {
      it("has the correct text", () => {
        const helpBlocks = getHelpBlocks({isSoloPlan: true, namesOfEligiblePeople: []});

        expect(helpBlocks.length).toEqual(1);
        expect(helpBlocks[0].props.children).toEqual(
          "At this time, we are only able to recommend cards issued by banks " +
          "in the United States. Don't worry, there are still tons of other " +
          "opportunities to reduce the cost of travel."
        );
      });
    });

    describe("when the person is eligible", () => {
      it("has the correct text", () => {
        const helpBlocks = getHelpBlocks({
          isSoloPlan: true,
          namesOfEligiblePeople: ["Peter"],
        });

        expect(helpBlocks.length).toEqual(2);

        expect(helpBlocks[0].props.children).toEqual(
          "What is your average monthly spending that could be charged to " +
          "a credit card account?"
        );

        expect(helpBlocks[1].props.children).toEqual(
          "You should exclude rent, mortage, and car payments unless you " +
          "are certain you can use a credit card as the payment method."
        );
      });
    });
  });

  describe("for the partner plan", () => {
    describe("when no-one is eligible", () => {
      it("has the correct text", () => {
        const helpBlocks = getHelpBlocks({isSoloPlan: false, namesOfEligiblePeople: []});

        expect(helpBlocks.length).toEqual(1);
        expect(helpBlocks[0].props.children).toEqual(
          "At this time, we are only able to recommend cards issued by banks " +
          "in the United States. Don't worry, there are still tons of other " +
          "opportunities to reduce the cost of travel."
        );
      });
    });

    describe("when one person is eligible", () => {
      it("has the correct text", () => {
        const helpBlocks = getHelpBlocks({
          isSoloPlan: false,
          namesOfEligiblePeople: ["Peter"],
        });

        expect(helpBlocks.length).toEqual(3);
        expect(helpBlocks[0].props.children).toEqual(
          "At this time, we are only able to recommend cards issued by banks " +
          "in the United States. Only Peter will receive credit card " +
          "recommendations, but we'll use your combined spending to make " +
          "sure you earn points as fast as possible."
        );
        expect(helpBlocks[1].props.children).toEqual(
          "Please estimate the combined monthly spending for Peter that " +
          "could be charged to a credit card account."
        );
        expect(helpBlocks[2].props.children).toEqual(
          "You should exclude rent, mortage, and car payments unless you " +
          "are certain you can use a credit card as the payment method."
        );
      });
    });

    describe("when both people are eligible", () => {
      it("has the correct text", () => {
        const helpBlocks = getHelpBlocks({
          isSoloPlan: false,
          namesOfEligiblePeople: ["Peter", "Lois"],
        });

        expect(helpBlocks.length).toEqual(2);
        expect(helpBlocks[0].props.children).toEqual(
          "Please estimate the combined monthly spending for Peter and Lois " +
          "that could be charged to a credit card account."
        );

        expect(helpBlocks[1].props.children).toEqual(
          "You should exclude rent, mortage, and car payments unless you " +
          "are certain you can use a credit card as the payment method."
        );
      });
    });
  });
});
