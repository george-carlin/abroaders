const React = require('react');

const HiddenFieldTag = require("../HiddenFieldTag");

const AuthTokenField = React.createClass({

  getInitialState() {
    return { csrfToken: "" }
  },


  componentDidMount() {
    // Hack to get the csrf-token into the form. `csrf_meta_tags` doesn't
    // output anything in test mode, so only add this hack if the querySelector
    // returns anything:
    var csrfMetaTag = document.querySelector('meta[name="csrf-token"]')
    if (csrfMetaTag) {
      this.setState({ csrfToken: csrfMetaTag.content });
    }
  },


  render() {
    return (
      <HiddenFieldTag
        name="authenticity_token"
        value={this.state.csrfToken}
      />
    );
  },
});

module.exports = AuthTokenField;
