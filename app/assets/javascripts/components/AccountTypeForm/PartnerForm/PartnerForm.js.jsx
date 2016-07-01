const React = require("react");

const Button = require("../../core/Button");
const FAIcon = require("../../core/FAIcon");
const Form   = require("../../core/Form");

const MonthlySpending = require("../MonthlySpending");
const PhoneNumber     = require("../PhoneNumber");

const Eligibility     = require("./Eligibility");
const NameFields      = require("./NameFields");

const PartnerForm = React.createClass({
  propTypes: {
    active:    React.PropTypes.bool,
    ownerName: React.PropTypes.string.isRequired,
    onChoose:  React.PropTypes.func.isRequired,
    path:      React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      monthlySpending:          null,
      nameSubmitted:            false,
      partnerName:              "",
      showMonthlySpendingError: false,
      showPartnerNameError:     false,
      eligibility:              "both",
    };
  },


  onChangeEligibility(e) {
    this.setState({eligibility: e.target.value});
  },


  onChangeMonthlySpending(e) {
    this.setState({monthlySpending: parseInt(e.target.value, 10)});
  },


  onChangePartnerName(e) {
    this.setState({ partnerName: e.target.value });
  },


  onSubmit(e) {
    if (this.state.nameSubmitted) {
      if (this.state.eligibility !== "neither" && !this.isMonthlySpendingPresentAndValid()) {
        e.preventDefault();
        this.setState({showMonthlySpendingError: true });
      } else {
        this.setState({showMonthlySpendingError: false });
      }
    } else {
      this.onSubmitPartnerName(e);
    }
  },


  onSubmitPartnerName(e, name) {
    e.preventDefault();

    if (this.state.partnerName.length) {
      this.setState({ showPartnerNameError: false, nameSubmitted: true });
      this.props.onChoose();
    } else {
      this.setState({ showPartnerNameError: true });
    }
  },

  isMonthlySpendingPresentAndValid() {
    return this.state.monthlySpending && this.state.monthlySpending > 0;
  },


  render() {
    let classes = "PartnerForm account_type_select well col-xs-12 col-md-4";
    if (this.props.active) classes += " col-md-offset-4";

    const modelName = "partner_account";

    let namesOfEligiblePeople;
    switch (this.state.eligibility) {
      case "both":
        namesOfEligiblePeople = [this.props.ownerName, this.state.partnerName];
        break;
      case "person_0":
        namesOfEligiblePeople = [this.props.ownerName];
        break;
      case "person_1":
        namesOfEligiblePeople = [this.state.partnerName];
        break;
      case "neither":
        namesOfEligiblePeople = [];
        break;
    }

    return (
      <Form
        action={this.props.path}
        className={classes}
        id="partner_earning_select"
        method="post"
        onSubmit={this.onSubmit}
      >
        <h2>
          <FAIcon user />
          <FAIcon user />
          &nbsp;
          Couples Earning
        </h2>

        {(() => {
          if (this.state.nameSubmitted) {
            return (
              <div className="account_type_form_step_1">
                <input
                  type="hidden"
                  name="partner_account[partner_first_name]"
                  value={this.state.partnerName}
                />

                <Eligibility
                  eligibility={this.state.eligibility}
                  onChange={this.onChangeEligibility}
                  person1FirstName={this.props.ownerName}
                  person2FirstName={this.state.partnerName}
                />

                <hr />

                <MonthlySpending
                  eligibility={this.state.eligibility}
                  modelName={modelName}
                  namesOfEligiblePeople={namesOfEligiblePeople}
                  onChange={this.onChangeMonthlySpending}
                  person0FirstName={this.props.ownerName}
                  person1FirstName={this.state.partnerName}
                  showError={this.state.showMonthlySpendingError}
                  value={this.state.monthlySpending}
                />

                <PhoneNumber
                  modelName={modelName}
                />

                <Button primary >
                  Submit
                </Button>
              </div>
            );
          } else {
            return (
              <div>
                <p>
                  This option is ideal if you share monthly spending with a
                  spouse or partner. Abroaders will help you maximize your
                  points as a team.
                </p>

                <p>
                  Couples earning only works if you pay your bills together. If
                  you would prefer to keep your expenses separate and pay
                  separately for your own monthly purchases, you should each
                  create your own Abroaders account and choose "Solo Earning"
                </p>

                <NameFields
                  name={this.state.partnerName}
                  onChange={this.onChangePartnerName}
                  onSubmit={this.onSubmitPartnerName}
                  showError={this.state.showPartnerNameError}
                />
              </div>
            );
          }
        })()}

      </Form>
    );
  },
});

module.exports = PartnerForm;
