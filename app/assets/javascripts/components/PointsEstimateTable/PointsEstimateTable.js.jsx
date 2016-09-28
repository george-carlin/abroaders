const React = require("react");
const $     = require("jquery");
const _     = require("underscore");

const Row   = require("../core/Row");
const Table = require("../core/Table");

const Header = require("./Header");
const TR     = require("./Row");

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
      const fromId = $from.val();
      const toId   = $to.val();

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
        <div className="col-xs-12 col-lg-8">
          <h3>Estimated Cost</h3>

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
