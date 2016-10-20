import React, { PropTypes } from "react";

import Button      from "../core/Button";
import FAIcon      from "../core/FAIcon";
import Form        from "../core/Form";
import HiddenField from "../core/HiddenField";

import CompanionNameField from "./CompanionNameField";

const CouplesForm = React.createClass({
  propTypes: {
    action:    PropTypes.string.isRequired,
    ownerName: PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      companionName: "",
      showError:     false,
    };
  },


  onChangeCompanionName(e) {
    this.setState({ companionName: e.target.value });
  },


  onSubmit(e) {
    if (this.state.companionName.trim().length) {
      this.setState({ showError: false});
    } else {
      e.preventDefault();
      this.setState({ showError: true });
    }
  },


  render() {
    return (
      <Form
        action={this.props.action}
        className="CouplesForm account_type_select well col-xs-12 col-md-4"
        method="post"
        onSubmit={this.onSubmit}
      >
        <HiddenField
          attribute="type"
          modelName={this.props.modelName}
          value="couples"
        />

        <h2>
          <FAIcon user />
          <FAIcon user />
          &nbsp;
          Couples Earning
        </h2>

        <div>
          <p>
            This option is ideal if you share monthly spending with a spouse or
            partner. Abroaders will help you maximize your points as a team.
          </p>

          <p>
            Couples earning only works if you pay your bills together. If you
            would prefer to keep your expenses separate and pay separately for
            your own monthly purchases, you should each create your own
            Abroaders account and choose "Solo Earning"
          </p>

          <CompanionNameField
            modelName={this.props.modelName}
            name={this.state.companionName}
            onChange={this.onChangeCompanionName}
            showError={this.state.showError}
          />

          <Button
            onClick={this.onSubmit}
            primary
          >
            Sign up for couples earning
          </Button>
        </div>
      </Form>
    );
  },
});

module.exports = CouplesForm;
