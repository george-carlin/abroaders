import React, { PropTypes } from "react";

import Button from "../core/Button";
import Cols   from "../core/Cols";
import FAIcon from "../core/FAIcon";
import Form   from "../core/Form";
import Row    from "../core/Row";

import columnClassnames from "../core/shared/columnClassnames";

import BusinessSpendingFormGroup from "./BusinessSpendingFormGroup";
import ErrorMessages             from "./ErrorMessages";
import HasBusinessFormGroup      from "./HasBusinessFormGroup";
import CreditScoreFormGroup      from "./CreditScoreFormGroup";
import WillApplyForLoanFormGroup from "./WillApplyForLoanFormGroup";
import MonthlySpendingFormGroup  from "./MonthlySpendingFormGroup";

const SpendingSurvey = React.createClass({
  propTypes: {
    defaultValues:      PropTypes.object,
    errorMessages:      PropTypes.array,
    ownerEligible:      PropTypes.bool,
    ownerFirstName:     PropTypes.string.isRequired,
    companionEligible:  PropTypes.bool,
    companionFirstName: PropTypes.string,
    submitPath:         PropTypes.string.isRequired,
  },

  getDefaultProps() {
    return {
      defaultValues: {},
    };
  },

  getInitialState() {
    return Object.assign(
      {
        companionHasBusiness:      "no_business",
        companionWillApplyForLoan: "false",
        ownerHasBusiness:          "no_business",
        ownerWillApplyForLoan:     "false",
      },
      this.props.defaultValues
    );
  },

  onChangeOwnerHasBusiness(e) {
    this.setState({ownerHasBusiness: e.target.value});
  },

  onChangeCompanionHasBusiness(e) {
    this.setState({companionHasBusiness: e.target.value});
  },

  companionHasBusiness() {
    return this.state.companionHasBusiness === "no_business";
  },

  ownerHasBusiness() {
    return this.state.ownerHasBusiness === "no_business";
  },

  render() {
    const props = this.props;
    const bothEligible = props.ownerEligible && props.companionEligible;

    if (!props.ownerEligible && !props.companionEligible) { // sanity check
      throw "at least one person must be eligible";
    }

    const colsClassName = columnClassnames({ xs: 12, md: bothEligible ? 6 : 12 });
    const ownerFormGroupProps = {
      className:  colsClassName,
      firstName:  props.ownerFirstName,
      personType: "owner",
      useName:    bothEligible,
    };
    const companionFormGroupProps = {
      className:  colsClassName,
      firstName:  props.companionFirstName,
      personType: "companion",
      useName:    bothEligible,
    };

    return (
      <Row className="hpanel">
        <Cols md={bothEligible ? 12 : 6} mdOffset={bothEligible ? 0 : 3} xs="12">
          {props.errorMessages.length ?
            <ErrorMessages messages={props.errorMessages} /> : null
          }
          <div className="panel-body">
            <Form action={props.submitPath}>
              <Row>
                <Cols xs="12" className="text-center">
                  <h1>Spending Information</h1>
                  <hr />
                </Cols>
              </Row>

              <Row>
                {props.ownerEligible ?
                  <CreditScoreFormGroup
                    defaultValue={this.state.ownerCreditScore}
                    {...ownerFormGroupProps}
                  /> : null
                }
                {props.companionEligible ?
                  <CreditScoreFormGroup
                    defaultValue={this.state.companionCreditScore}
                    {...companionFormGroupProps}
                  /> : null
                }
              </Row>

              <Row>
                <MonthlySpendingFormGroup
                  className={columnClassnames({ xs: 12})}
                  defaultValue={this.state.monthlySpending}
                />
              </Row>

              <Row>
                {props.ownerEligible ?
                  <div className={colsClassName}>
                    <HasBusinessFormGroup
                      defaultValue={this.state.ownerHasBusiness}
                      onChange={this.onChangeOwnerHasBusiness}
                      {...ownerFormGroupProps}
                    />

                    {this.state.ownerHasBusiness !== "no_business" ?
                      <BusinessSpendingFormGroup
                        defaultValue={this.ownerBusinessSpending}
                        {...ownerFormGroupProps}
                      /> : null
                    }
                  </div> : null
                }
                {props.companionEligible ?
                  <div className={colsClassName}>
                    <HasBusinessFormGroup
                      defaultValue={this.state.companionHasBusiness}
                      onChange={this.onChangeCompanionHasBusiness}
                      {...companionFormGroupProps}
                    />

                    {this.state.companionHasBusiness !== "no_business" ?
                      <BusinessSpendingFormGroup
                        defaultValue={this.companionBusinessSpending}
                        {...companionFormGroupProps}
                      /> : null
                    }
                  </div> : null
                }
              </Row>

              <Row>
                {props.ownerEligible ?
                  <WillApplyForLoanFormGroup
                    defaultValue={this.state.ownerWillApplyForLoan}
                    {...ownerFormGroupProps}
                  /> : null
                }
                {props.companionEligible ?
                  <WillApplyForLoanFormGroup
                    defaultValue={this.state.companionWillApplyForLoan}
                    {...companionFormGroupProps}
                  /> : null
                }
              </Row>

              <Row>
                <hr style={{marginTop: 0}} />
                <Cols xs="12">
                  <Button primary large >
                    <FAIcon check />&nbsp;
                    Save and continue
                  </Button>
                </Cols>
              </Row>
            </Form>
          </div>
        </Cols>
      </Row>
    );
  },
});

module.exports = SpendingSurvey;
