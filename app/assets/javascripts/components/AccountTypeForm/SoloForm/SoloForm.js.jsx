const React = require("react");

const Button = require("../../core/Button");
const Form   = require("../../core/Form");

const Step0 = require("./Step0");
const Step1 = require("./Step1");

const SoloForm = React.createClass({
  propTypes: {
    path: React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      isSigningUp:       false,
      isEligibleToApply: true,
      monthlySpending:   null,
      showMonthlySpendingError: false,
    };
  },


  showStep1(e) {
    e.preventDefault();
    this.setState({isSigningUp: true});
  },


  updateEligibilityTo(eligibility) {
    this.setState({isEligibleToApply: eligibility})
  },

  onChangeMonthlySpending(e) {
    const val = parseInt(e.target.value, 10);
    this.setState({monthlySpending: isNaN(val) ? null : val});
  },


  onSubmit(e) {
    if (this.state.isEligibleToApply) {
      if (this.isMonthlySpendingPresentAndValid()) {
        this.setState({showMonthlySpendingError: false});
      } else {
        this.setState({showMonthlySpendingError: true});
        e.preventDefault();
      }
    }
    // If everything is fine then let the <form> submit in the normal HTML way.
  },


  isMonthlySpendingPresentAndValid() {
    return this.state.monthlySpending && this.state.monthlySpending > 0
  },


  render() {
    return (
      <Form
        action={this.props.path}
        className="account_type_select well col-xs-12 col-md-4 col-md-offset-2"
        id="solo_earning_select"
        method="post"
        onSubmit={this.onSubmit}
      >
        <h2>Solo Earning</h2>


        {(() => {
          if (this.state.isSigningUp) {
            return (
              <Step1
                isEligibleToApply={this.state.isEligibleToApply}
                monthlySpending={this.state.monthlySpending}
                onChangeEligibility={this.updateEligibilityTo}
                onChangeMonthlySpending={this.onChangeMonthlySpending}
                showMonthlySpendingError={this.state.showMonthlySpendingError}
              />
            );
          } else {
            return <Step0 onSubmit={this.showStep1} />;
          }
        })()}

      </Form>
    );
  },
});

module.exports = SoloForm;
