import React, { Component } from 'react';
import { Form, Row, Col, Button } from 'react-bootstrap';
import Calendar from 'react-calendar'

class ClientTrade extends Component {
    // render() {
    //     return (
    //         <div>
    //             {this.formRender}
    //         </div>
    //     );
    // }

    render() {
        return (

            <div>
                <h2>Enter trade details</h2>
                <Form>
                    <Form.Group as={Row}/>
                    <Form.Group as={Row}/>
                    <Form.Group as={Row} controlId="formHorizontalEmail">
                        <Col sm={2} />
                        <Form.Label column sm={2}>
                            MarkitWire Trade id
                        </Form.Label>
                        <Col sm={2}>
                            <Form.Control type="text" placeholder="MarkitWire Id" />
                        </Col>
                    </Form.Group>

                    <Form.Group as={Row} controlId="formHorizontalPassword">
                        <Col sm={2} />

                        <Form.Label column sm={2}>
                            Trade date
                        </Form.Label>
                        <Col sm={2}>
                            <Form.Control type="text" placeholder="Trade date" />
                        </Col>
                    </Form.Group>
                    <Form.Group as={Row} controlId="formHorizontalPassword">
                        <Col sm={2} />

                        <Form.Label column sm={2}>
                            Currency
                        </Form.Label>
                        <Col sm={2}>
                            <Form.Control type="text" placeholder="Currency" />
                        </Col>
                    </Form.Group>
                    <Form.Group as={Row} controlId="formHorizontalPassword">
                        <Col sm={2} />

                        <Form.Label column sm={2}>
                            Settlement date
                        </Form.Label>
                        <Col sm={2}>
                            <Form.Control type="text" placeholder="Settlement date" />
                        </Col>
                    </Form.Group>
                    <Form.Group as={Row} controlId="formHorizontalPassword">
                        <Col sm={2} />

                        <Form.Label column sm={2}>
                            Broker code
                        </Form.Label>
                        <Col sm={2}>
                            <Form.Control type="text" placeholder="broker " />
                        </Col>
                    </Form.Group>
                    <Form.Group as={Row} controlId="formHorizontalPassword">
                        <Col sm={2} />

                        <Form.Label column sm={2}>
                            Brokerage fee
                        </Form.Label>
                        <Col sm={2}>
                            <Form.Control type="text" placeholder="amount" />
                        </Col>
                    </Form.Group>
                    
                    <Form.Group as={Row}/>
                    

                    <Form.Group as={Row}>
                    <Col sm={2} />
                    <Col sm={2} />
                        <Col sm={2}>
                            <Button variant="primary" type="submit">
                                Submit
                    </Button>
                        </Col>
                    </Form.Group>
                </Form>
            </div>
        );

    }
}


export default ClientTrade;