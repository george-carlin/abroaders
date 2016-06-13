const path = "../../Alert";

jest.unmock(path);

const React     = require('react');
const ReactDOM  = require('react-dom');
const TestUtils = require('react-addons-test-utils');
const _         = require('underscore');

const Alert = require(path);

describe('Alert', () => {
  const renderAlert = (props) => {
    const alert = TestUtils.renderIntoDocument(<Alert {...props} />);
    return ReactDOM.findDOMNode(alert);
  };

  describe("with no props", () => {
    it("has an 'alert' CSS class", () => {
      const alert = renderAlert();
      expect(_.includes(alert.classList, "alert")).toBeTruthy();
    });
  });

  describe("with 'danger' prop", () => {
    it("has an 'alert-danger' CSS class", () => {
      const alert = renderAlert({ danger: true });
      expect(_.includes(alert.classList, "alert")).toBeTruthy();
      expect(_.includes(alert.classList, "alert-danger")).toBeTruthy();
    });
  });

  describe("with 'info' prop", () => {
    it("has an 'alert-info' CSS class", () => {
      const alert = renderAlert({ info: true });
      expect(_.includes(alert.classList, "alert")).toBeTruthy();
      expect(_.includes(alert.classList, "alert-info")).toBeTruthy();
    });
  });

  describe("with 'success' prop", () => {
    it("has an 'alert-success' CSS class", () => {
      const alert = renderAlert({ success: true });
      expect(_.includes(alert.classList, "alert")).toBeTruthy();
      expect(_.includes(alert.classList, "alert-success")).toBeTruthy();
    });
  });

  describe("with 'warning' prop", () => {
    it("has an 'alert-warning' CSS class", () => {
      const alert = renderAlert({ warning: true });
      expect(_.includes(alert.classList, "alert")).toBeTruthy();
      expect(_.includes(alert.classList, "alert-warning")).toBeTruthy();
    });
  });
});
