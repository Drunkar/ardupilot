/// -*- tab-width: 4; Mode: C++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#if FRAME_CONFIG ==	QUAD_FRAME

void output_motors_armed()
{
	int roll_out, pitch_out;
	int out_min = g.rc_3.radio_min;
	int out_max = g.rc_3.radio_max;

	// Throttle is 0 to 1000 only
	g.rc_3.servo_out 	= constrain(g.rc_3.servo_out, 0, 1000);

	if(g.rc_3.servo_out > 0)
		out_min = g.rc_3.radio_min + MINIMUM_THROTTLE;

	g.rc_1.calc_pwm();
	g.rc_2.calc_pwm();
	g.rc_3.calc_pwm();
	g.rc_4.calc_pwm();

	if(g.frame_orientation == X_FRAME){
		roll_out 	 	= g.rc_1.pwm_out * .707;
		pitch_out 	 	= g.rc_2.pwm_out * .707;

		// left
		motor_out[CH_3]	 	= g.rc_3.radio_out + roll_out + pitch_out;	// FRONT
		motor_out[CH_2]	 	= g.rc_3.radio_out + roll_out - pitch_out;	// BACK

		// right
		motor_out[CH_1]		= g.rc_3.radio_out - roll_out + pitch_out;  // FRONT
		motor_out[CH_4] 	= g.rc_3.radio_out - roll_out - pitch_out;	// BACK

	}else{

		roll_out 	 	= g.rc_1.pwm_out;
		pitch_out 	 	= g.rc_2.pwm_out;

		// left
		motor_out[CH_1]		= g.rc_3.radio_out - roll_out;
		// right
		motor_out[CH_2]		= g.rc_3.radio_out + roll_out;
		// front
		motor_out[CH_3]		= g.rc_3.radio_out + pitch_out;
		// back
		motor_out[CH_4] 	= g.rc_3.radio_out - pitch_out;
	}

	// Yaw input
	motor_out[CH_1]		+=  g.rc_4.pwm_out; 	// CCW
	motor_out[CH_2]		+=  g.rc_4.pwm_out; 	// CCW
	motor_out[CH_3]		-=  g.rc_4.pwm_out; 	// CW
	motor_out[CH_4] 	-=  g.rc_4.pwm_out; 	// CW

	// limit output so motors don't stop
	motor_out[CH_1]		= max(motor_out[CH_1], 	out_min);
	motor_out[CH_2]		= max(motor_out[CH_2], 	out_min);
	motor_out[CH_3]		= max(motor_out[CH_3], 	out_min);
	motor_out[CH_4] 	= max(motor_out[CH_4], 	out_min);

	motor_out[CH_1]		= min(motor_out[CH_1], 	out_max);
	motor_out[CH_2]		= min(motor_out[CH_2], 	out_max);
	motor_out[CH_3]		= min(motor_out[CH_3], 	out_max);
	motor_out[CH_4] 	= min(motor_out[CH_4], 	out_max);

	#if CUT_MOTORS == ENABLED
		// Send commands to motors
		if(g.rc_3.servo_out > 0){
			APM_RC.OutputCh(CH_1, motor_out[CH_1]);
			APM_RC.OutputCh(CH_2, motor_out[CH_2]);
			APM_RC.OutputCh(CH_3, motor_out[CH_3]);
			APM_RC.OutputCh(CH_4, motor_out[CH_4]);
		}else{
			APM_RC.OutputCh(CH_1, g.rc_3.radio_min);
			APM_RC.OutputCh(CH_2, g.rc_3.radio_min);
			APM_RC.OutputCh(CH_3, g.rc_3.radio_min);
			APM_RC.OutputCh(CH_4, g.rc_3.radio_min);
		}
	#else
		APM_RC.OutputCh(CH_1, motor_out[CH_1]);
		APM_RC.OutputCh(CH_2, motor_out[CH_2]);
		APM_RC.OutputCh(CH_3, motor_out[CH_3]);
		APM_RC.OutputCh(CH_4, motor_out[CH_4]);
	#endif
	// InstantPWM
	APM_RC.Force_Out0_Out1();
	APM_RC.Force_Out2_Out3();
}

void output_motors_disarmed()
{
	if(g.rc_3.control_in > 0){
		// we have pushed up the throttle
		// remove safety
		motor_auto_armed = true;
	}

	// fill the motor_out[] array for HIL use
	for (unsigned char i = 0; i < 8; i++) {
		motor_out[i] = g.rc_3.radio_min;
	}

	// Send commands to motors
	APM_RC.OutputCh(CH_1, g.rc_3.radio_min);
	APM_RC.OutputCh(CH_2, g.rc_3.radio_min);
	APM_RC.OutputCh(CH_3, g.rc_3.radio_min);
	APM_RC.OutputCh(CH_4, g.rc_3.radio_min);

	// InstantPWM
	APM_RC.Force_Out0_Out1();
	APM_RC.Force_Out2_Out3();
}

void output_motor_test()
{
	motor_out[CH_1] = g.rc_3.radio_min;
	motor_out[CH_2] = g.rc_3.radio_min;
	motor_out[CH_3] = g.rc_3.radio_min;
	motor_out[CH_4] = g.rc_3.radio_min;


	if(g.frame_orientation == X_FRAME){
//  31
//	24
		if(g.rc_1.control_in > 3000){
			motor_out[CH_1] += 50;
			motor_out[CH_4] += 50;
		}

		if(g.rc_1.control_in < -3000){
			motor_out[CH_2] += 50;
			motor_out[CH_3] += 50;
		}

		if(g.rc_2.control_in > 3000){
			motor_out[CH_2] += 50;
			motor_out[CH_4] += 50;
		}

		if(g.rc_2.control_in < -3000){
			motor_out[CH_1] += 50;
			motor_out[CH_3] += 50;
		}

	}else{
//  3
// 2 1
//	4
		if(g.rc_1.control_in > 3000)
			motor_out[CH_1] += 50;

		if(g.rc_1.control_in < -3000)
			motor_out[CH_2] += 50;

		if(g.rc_2.control_in > 3000)
			motor_out[CH_4] += 50;

		if(g.rc_2.control_in < -3000)
			motor_out[CH_3] += 50;
	}

	APM_RC.OutputCh(CH_1, motor_out[CH_1]);
	APM_RC.OutputCh(CH_2, motor_out[CH_2]);
	APM_RC.OutputCh(CH_3, motor_out[CH_3]);
	APM_RC.OutputCh(CH_4, motor_out[CH_4]);
}

#endif