jest.dontMock("../LoadingSpinner.js.jsx");

const LoadingSpinner = require("../LoadingSpinner.js.jsx");

describe("LoadingSpinner", () => {
  const React          = require("react/addons");
  const TestUtils      = React.addons.TestUtils;

  describe("when the 'hidden' property", () => {
    describe("is not provided", () => {
      it("is visible", () => {
        const node = TestUtils.renderIntoDocument(
          <LoadingSpinner />
        ).getDOMNode();
        expect(node.style.display).not.toEqual("none");
      });
    });

    describe("is true", () => {
      it("is hidden", () => {
        const node = TestUtils.renderIntoDocument(
          <LoadingSpinner hidden />
        ).getDOMNode();
        expect(node.style.display).toEqual("none");
      });
    });
  });
});
