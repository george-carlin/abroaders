const React = require("react");

const Button = require("../../core/Button");
const FAIcon = require("../../core/FAIcon");
const Form   = require("../../core/Form");

const Step0 = require("./Step0");
const Step1 = require("./Step1");

const SoloForm = React.createClass({
  propTypes: {
    active:   React.PropTypes.bool,
    onChoose: React.PropTypes.func.isRequired,
    path:     React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      isSigningUp:       false,
      isEligibleToApply: true,
      monthlySpending:   null,
      showMonthlySpendingError: false,
    };
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


  updateEligibilityTo(eligibility) {
    this.setState({isEligibleToApply: eligibility});
  },


  showStep1(e) {
    e.preventDefault();
    this.props.onChoose();
    this.setState({isSigningUp: true});
  },


  isMonthlySpendingPresentAndValid() {
    return this.state.monthlySpending && this.state.monthlySpending > 0;
  },


  render() {
    let classes = "SoloForm account_type_select well col-xs-12 col-md-4";
    if (this.props.active) {
      classes += " col-md-offset-4 active";
    } else {
      classes += " col-md-offset-2 inactive";
    }

    return (
      <Form
        action={this.props.path}
        className={classes}
        id="solo_earning_select"
        method="post"
        onSubmit={this.onSubmit}
      >
        <h2>
          <FAIcon user />
          &nbsp;
          Solo Earning
        </h2>


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
