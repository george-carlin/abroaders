jest.dontMock("../LoadingSpinner.js.jsx");

const LoadingSpinner = require("../LoadingSpinner.js.jsx");

describe("LoadingSpinner", () => {
  const React     = require("react/addons");
  const ReactDOM  = require("react-dom");
  const TestUtils = React.addons.TestUtils;

  describe("when the 'hidden' property", () => {
    describe("is not provided", () => {
      it("is visible", () => {
        const spinner = ReactDOM.findDOMNode(
          TestUtils.renderIntoDocument(<LoadingSpinner />)
        )
        expect(spinner.style.display).not.toEqual("none");
      });
    });

    describe("is true", () => {
      it("is hidden", () => {
        const spinner = ReactDOM.findDOMNode(
          TestUtils.renderIntoDocument(<LoadingSpinner hidden />)
        )
        expect(spinner.style.display).toEqual("none");
      });
    });
  });
});
