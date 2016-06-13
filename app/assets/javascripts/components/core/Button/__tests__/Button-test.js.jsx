const path = "../../Button";

jest.unmock(path);

const React     = require('react');
const ReactDOM  = require('react-dom');
const TestUtils = require('react-addons-test-utils');
const _         = require('underscore');

const Button = require(path);

describe('Button', () => {
  const renderButton = (props) => {
    const button = TestUtils.renderIntoDocument(<Button {...props} />);
    return ReactDOM.findDOMNode(button);
  };

  describe("with no props", () => {
    it("has a 'btn' CSS class", () => {
      const button = renderButton();
      expect(_.includes(button.classList, "btn")).toBeTruthy();
    });
  });

  describe("'default' prop", () => {
    it("adds a 'btn-default' CSS class", () => {
      const button = renderButton({ default: true });
      expect(_.includes(button.classList, "btn")).toBeTruthy();
      expect(_.includes(button.classList, "btn-default")).toBeTruthy();
    });
  });

  describe("'large' prop", () => {
    it("adds a 'btn-lg' CSS class", () => {
      const button = renderButton({ large: true });
      expect(_.includes(button.classList, "btn")).toBeTruthy();
      expect(_.includes(button.classList, "btn-lg")).toBeTruthy();
    });
  });

  describe("'primary' prop", () => {
    it("adds a 'btn-primary' CSS class", () => {
      const button = renderButton({ primary: true });
      expect(_.includes(button.classList, "btn")).toBeTruthy();
      expect(_.includes(button.classList, "btn-primary")).toBeTruthy();
    });
  });

  describe("'small' prop", () => {
    it("adds a 'btn-sm' CSS class", () => {
      const button = renderButton({ small: true });
      expect(_.includes(button.classList, "btn")).toBeTruthy();
      expect(_.includes(button.classList, "btn-sm")).toBeTruthy();
    });
  });
});
