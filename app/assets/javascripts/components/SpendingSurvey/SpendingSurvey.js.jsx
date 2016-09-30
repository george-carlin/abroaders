const React = require("react");

const Button = require("../core/Button");
const Form   = require("../core/Form");
const Row    = require("../core/Row");

const BusinessInfo     = require("./BusinessInfo");
const CreditScore      = require("./CreditScore");
const WillApplyForLoan = require("./WillApplyForLoan");
const MonthlySpendingFormGroup = require("./MonthlySpendingFormGroup");
const MonthlySpendingHelpText  = require("./MonthlySpendingHelpText");

const SpendingSurvey = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
  },

  render() {
    const account   = this.props.account;
    const owner     = account.owner;
    const companion = account.companion;
    const hasCompanion = !!companion;

    const showOwner     = !!owner.eligible;
    const showCompanion = !!(companion && companion.eligible);

    if (!showOwner && !showCompanion) { // sanity check
      throw "at least one person must be eligible";
    }

    const showBoth = showOwner && showCompanion;

    const businessInfos = [];
    const creditScores  = [];
    const wA4Ls         = [];

    const sharedProps = {
      className: `col-xs-12 col-md-${!showBoth ? 12 : 6}`,
      modelName: "spending_survey",
      useName:   hasCompanion,
    };

    if (showOwner) {
      sharedProps.key    = 0;
      sharedProps.person = owner;
      businessInfos.push(<BusinessInfo {...sharedProps} />);
      creditScores.push(<CreditScore {...sharedProps} />);
      wA4Ls.push(<WillApplyForLoan {...sharedProps} />);
    }
    if (showCompanion) {
      sharedProps.key    = 1;
      sharedProps.person = companion;
      businessInfos.push(<BusinessInfo {...sharedProps} />);
      creditScores.push(<CreditScore {...sharedProps} />);
      wA4Ls.push(<WillApplyForLoan {...sharedProps} />);
    }

    let cols = "col-xs-12";
    if (!showBoth) cols += " col-md-6 col-md-offset-3";

    const names = [account.owner.firstName];
    if (account.companion) {
      names.push(account.companion.firstName);
    }

    return (
      <div className="hpanel row">
        <div className={`panel-body ${cols}`}>
          <Form action={this.props.submitPath}>
            <Row>
              <div className="col-xs-12 text-center">
                <h1>Spending Information</h1>
              </div>
            </Row>

            <Row>
              {creditScores}
            </Row>
            <Row>
              <div className="col-xs-12 col-md-6 col-md-offset-3">
                <h3>How much do you spend per month?</h3>
                <MonthlySpendingHelpText firstNames={names} />
                <MonthlySpendingFormGroup modelName={sharedProps.modelName} />
              </div>
            </Row>
            <Row>{businessInfos}</Row>
            <Row>{wA4Ls}</Row>

            <Row>
              <hr />
              <div className="col-xs-12">
                <Button primary large >
                  Submit
                </Button>
              </div>
            </Row>
          </Form>
        </div>
      </div>
    );
  },
});

module.exports = SpendingSurvey;
