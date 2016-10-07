/* global $ */
import React from "react";
import $     from "jquery";
import _     from "underscore";

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
    const $fromSelect = $("#travel_plan_from_id");
    const $toSelect   = $("#travel_plan_to_id");
    const $typeSelect = $("input[name='travel_plan[type]']");
    const $noOfPsgrs  = $("input[name='travel_plan[no_of_passengers]']");

    const onChangePointsEstimateParam = () => {
      const $from  = $fromSelect.children(":selected");
      const $to    = $toSelect.children(":selected");

      const fromCode = $from.data("code");
      const toCode   = $to.data("code");
      const type     = $typeSelect.filter(":checked").val();
      const psgrs    = parseInt($noOfPsgrs.val(), 10);

      if (fromCode && toCode && psgrs > 0) {
        const url = `/estimates/${fromCode}/${toCode}/${type}/${psgrs}`;

        $.get(url, (data) => { this.setState({data}); });
      }
    };

    $fromSelect.change(onChangePointsEstimateParam);
    $toSelect.change(onChangePointsEstimateParam);
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
