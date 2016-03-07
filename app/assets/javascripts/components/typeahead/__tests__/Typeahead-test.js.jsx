// TODO I'm finding I'm basically using 'dontMock' for everything, which
// suggests that I don't actually know how to use Jest mocking properly.
// Figure it out.
jest.dontMock("../Typeahead.js.jsx");
jest.dontMock("../../LoadingSpinner/LoadingSpinner.js.jsx");
jest.dontMock("../../TypeaheadDropdownMenu/TypeaheadDropdownMenu.js.jsx");
jest.dontMock("../../TypeaheadItem/TypeaheadItem.js.jsx");

var sampleData = [
  { name: "Claire" },
  { name: "Dave" },
  { name: "Drew" },
  { name: "Jimmy" },
  { name: "Joanna" },
  { name: "John" },
  { name: "Kevin" },
  { name: "Mike" },
  { name: "Paul" },
  { name: "Robert" },
  { name: "Sarah" },
  { name: "Sue" },
  { name: "Susan" },
  { name: "Taylor" },
];

const Typeahead = require("../Typeahead.js.jsx");

describe("Typeahead", () => {
  const React     = require("react/addons");
  const ReactDOM  = require("react-dom");
  const TestUtils = React.addons.TestUtils;
  const $         = require("jquery");
  const _         = require("underscore");

  const getKeyEvent = (key) => {
    const e = { keyIdentifier: key };
    e.keyCode = e.charCode = e.which = {
      "Enter" : 13,
      "Up"    : 38,
      "Down"  : 40,
      // add more keys as we need them.
    }[key];
    return e;
  };

  const inputKeyDown = (key) => {
    TestUtils.Simulate.keyDown(input, getKeyEvent(key));
  };

  const inputKeyPress = (key) => {
    TestUtils.Simulate.keyPress(input, getKeyEvent(key));
  };

  var typeahead, props, menu, input;

  beforeEach(() => {
    jasmine.clock().uninstall();
    jasmine.clock().install()

    if (!props) props = {};

    // Typeahead's search function runs asynchronously, meaning we need to use
    // Jasmine's 'done' callback to make it wait for async callbacks to
    // complete. This is tricky, and the solution is a bit hacky:
    //
    // 1. if the test is going to call the search function (which should be
    //    most tests), pass 'done' to it() then set `this.globalDone` to `done`.
    // 2. in the async callback that gets passed to Typeahead.source, call
    //    `this.globalDone()` if it's been set.
    //
    // I don't really like this is solution as it requires a lot of repetition
    // in each it block, but I can't come up with anything better for now.
    var that = this;

    props.source = (query, syncCallback, asyncCallback) => {
      // TODO right now Typeahead is only handling async results because we
      // don't have any caching. Once we update Typeahead, we'll need to update
      // this mock to test the searching of cached results.
      syncCallback([]);

      const results = sampleData.filter((item) => {
        return item.name.toLowerCase().includes(query.toLowerCase());
      });
      // Use setTimeout to get the asyncy-ness:
      setTimeout(
        () => {
          asyncCallback(results);
          if (that.globalDone) that.globalDone();
        },
        0,
        results
      );
      jasmine.clock().tick(1)
    };

    typeahead = ReactDOM.findDOMNode(
      TestUtils.renderIntoDocument(
        React.createElement(Typeahead, props)
      )
    );
    menu  = typeahead.querySelector(".TypeaheadDropdownMenu");
    input = typeahead.querySelector(".TypeaheadInput");
  });


  const typeQuery = (query) => {
    input.value = query;
    TestUtils.Simulate.change(input);
  };


  describe("typing in a search query", () => {
    describe("that returns no results", () => {
      it("does not show the dropdown menu", (done) => {
        this.globalDone = done;
        typeQuery("qwertyuio");
        expect(menu.style.display).toEqual("none");
      });
    });

    describe("that returns some results", () => {
      // Can't use beforeEach because we need to set 'this.globalDone' to 'done'
      // within each 'it' block. So pass 'done' to this func from within 'it':
      function setup(done) {
        this.globalDone = done;
        typeQuery("r");
      }

      beforeEach(() => setup = setup.bind(this));

      it("shows them in the dropdown menu", (done) => {
        setup(done);
        expect(menu.style.display).not.toEqual("none");
        // Results:  Robert, Sarah, Drew, Taylor, Claire;
        expect(menu.childElementCount).toEqual(5);
        expect(menu.childElementCount).toEqual(5);
      });

      describe("the first item in the menu", () => {
        it("is highlighted", (done) => {
          setup(done);
          expect(menu.children[0].className).toMatch(/\bactive\b/)
        });
      });

      describe("pressing return", () => {
        it("selects the highlighted (i.e. first) item", (done) => {
          setup(done);
          const firstItem = menu.children[0].textContent;
          inputKeyPress("Enter");
          expect(menu.style.display).toEqual("none");
          expect(input.value).toEqual(firstItem);
        });
      });

      describe("and clicking a result", () => {
        var item;

        function moreSetup(done) {
          setup(done);
          item = _.find(menu.children, (li) => li.textContent === "Taylor" );
          TestUtils.Simulate.click(item);
          TestUtils.Simulate.click(item);
        }
        beforeEach(() => moreSetup = moreSetup.bind(this));

        it("hides the dropdown", (done) => {
          moreSetup(done);
          expect(menu.style.display).toEqual("none");
        });

        it("populates the text input with the clicked item", (done) => {
          moreSetup(done);
          expect(input.value).toEqual("Taylor");
        });
      });


      describe("and pressing the down arrow key", () => {
        function moreSetup(done) {
          setup(done);
          inputKeyDown("Down");
        }
        beforeEach(() => moreSetup = moreSetup.bind(this));

        it("highlights the second item in the list", (done) => {
          moreSetup(done);
          expect(menu.children[1].className).toMatch(/\bactive\b/)
        });

        describe("twice", () => {
          function stillMoreSetup(done) {
            moreSetup(done);
            inputKeyDown("Down");
          }
          beforeEach(() => stillMoreSetup = stillMoreSetup.bind(this));

          it("highlights the third item in the list", (done) => {
            stillMoreSetup(done);
            expect(menu.children[2].className).toMatch(/\bactive\b/)
          });
        });
      }); // pressing the down arrow key


      describe("and pressing the up arrow key", () => {
        function moreSetup(done) {
          setup(done);
          inputKeyDown("Up");
        }
        beforeEach(() => moreSetup = moreSetup.bind(this));

        it("highlights the last item in the list", (done) => {
          moreSetup(done);
          var noOfItems = menu.children.length;
          expect(menu.children[noOfItems - 1].className).toMatch(/\bactive\b/)
        });

        describe("twice", () => {
          function stillMoreSetup(done) {
            setup(done);
            inputKeyDown("Up");
          }
          beforeEach(() => stillMoreSetup = stillMoreSetup.bind(this));

          it("highlights the last but one item in the list", (done) => {
            stillMoreSetup(done);
            var noOfItems = menu.children.length;
            expect(menu.children[noOfItems - 2].className).toMatch(/\bactive\b/)
          });
        });
      }); // pressing the down arrow key
    });
  });
});
