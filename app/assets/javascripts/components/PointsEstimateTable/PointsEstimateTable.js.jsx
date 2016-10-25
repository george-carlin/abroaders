/* global $ */
import React from "react";
import _     from "underscore";

// FIXME: importing $, as opposed to using window.$ (added by the asset
// pipeline), breaks the form. travel_plans_form.js manually triggers a change
// event on the 'code' hidden inputs, but if we import $ in here then our
// change handler doesn't get called. Presumably this is because the two files
// are using different copies of the jQuery object, so don't have access to
// each other's 'events' data (jQuery stores events internally, see
// http://stackoverflow.com/questions/2518421)
// import $     from "jquery";

import Row   from "../core/Row";
import Table from "../core/Table";

import Header from "./Header";
import TR from "./Row";

const PointsEstimateTable = React.createClass({
  getInitialState() {
    return { data: {} };
  },

  componentDidMount() {
    // Yet another hacky solution mixing jQuery and React :(
    const $from       = $("#travel_plan_from");
    const $to         = $("#travel_plan_to");
    const $typeSelect = $("input[name='travel_plan[type]']");
    const $noOfPsgrs  = $("input[name='travel_plan[no_of_passengers]']");

    const codeRegex = /\(([A-Z]{3})\)\s*$/;

    const onChangePointsEstimateParam = () => {
      const fromMatch = codeRegex.exec($from.val());
      const toMatch   = codeRegex.exec($from.val());
      if (!fromMatch || !toMatch) return;
      const fromCode = fromMatch[1];
      const toCode   = toMatch[1];
      const type     = $typeSelect.filter(":checked").val();
      const psgrs    = parseInt($noOfPsgrs.val(), 10);

      if (fromCode && toCode && psgrs > 0) {
        const url = `/estimates/${fromCode}/${toCode}/${type}/${psgrs}`;

        $.get(url, (data) => { this.setState({data}); });
      }
    };

    $from.change(onChangePointsEstimateParam);
    $to.change(onChangePointsEstimateParam);
    $typeSelect.click(onChangePointsEstimateParam);
    $noOfPsgrs.change(onChangePointsEstimateParam);
  },

  render() {
    if (_.isEmpty(this.state.data)) {
      return <noscript />;
    }

    const data = this.state.data;

    return (
      <Row className="PointsEstimateTable">
        <div className="col-xs-12 col-sm-12 col-md-12 col-lg-12">
          <span className="EstimatedCost">Estimated Cost</span>

          <Table
            id="travel_plan_points_estimate_table"
            striped
          >
            <Header />
            <tbody>
              <TR
                cosName="Economy"
                points={data.points.economy}
                fees={data.fees.economy}
              />
              <TR
                cosName="Business"
                points={data.points.business_class}
                fees={data.fees.business_class}
              />
              <TR
                cosName="First"
                points={data.points.first_class}
                fees={data.fees.first_class}
              />
            </tbody>
          </Table>
        </div>
      </Row>
    );
  },
});

module.exports = PointsEstimateTable;
