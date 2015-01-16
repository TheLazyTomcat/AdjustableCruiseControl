unit SCS_Telemetry_Condensed;

{==============================================================================}
{  SCS Telemetry API headers condenser, version 1.0a                           }
{  Condensed on: Friday 2014-11-07 21:04:26                                    }
{==============================================================================}

interface

{$IFDEF x64}
  {$DEFINE SCS_ARCHITECTURE_x64}
{$ELSE}
  {$DEFINE SCS_ARCHITECTURE_x86}
{$ENDIF}

{.$DEFINE AssertTypeSize}

{$IFDEF Debug}
  {$DEFINE AssertTypeSize}
{$ENDIF}

{$IFDEF Release}
  {$UNDEF AssertTypeSize}
{$ENDIF}

{=== scssdk.pas ===============================================================}
(**
 * @file scssdk.h
 *
 * @brief Common SDK types and structures.
 *)

// String types used in the API.
type
  TUTF8Char = type AnsiChar;  PUTF8Char = ^TUTF8Char;
  
  TelemetryString = type UTF8String;

// Types used trough the SDK.
  scs_u8_t      = Byte;               p_scs_u8_t      = ^scs_u8_t;
  scs_u16_t     = Word;               p_scs_u16_t     = ^scs_u16_t;
  scs_s32_t     = LongInt; {Integer}  p_scs_s32_t     = ^scs_s32_t;
  scs_u32_t     = LongWord;{Cardinal} p_scs_u32_t     = ^scs_u32_t;
  scs_u64_t     = UInt64;             p_scs_u64_t     = ^scs_u64_t;
  scs_float_t   = Single;             p_scs_float_t   = ^scs_float_t;
  scs_double_t  = Double;             p_scs_double_t  = ^scs_double_t;
  scs_string_t  = PUTF8Char;          p_scs_string_t  = ^scs_string_t;

const
  SCS_U32_NIL = scs_u32_t(-1);

(**
 * @brief Type of value provided during callback registration and passed back
 * to the callback.
 *)
type
  scs_context_t = Pointer;

(**
 * @brief Timestamp value.
 *
 * Value is expressed in microseconds.
 *)
type
  scs_timestamp_t = scs_u64_t;
  p_scs_timestamp_t = ^scs_timestamp_t;

// Common return codes.
type
  scs_result_t = scs_s32_t;
  p_scs_result_t = ^scs_result_t;

const
  SCS_RESULT_ok                 = scs_result_t(0);  // Operation succeeded.
  SCS_RESULT_unsupported        = scs_result_t(-1); // Operation or specified parameters are not supported. (e.g. the plugin does not support the requested version of the API)
  SCS_RESULT_invalid_parameter  = scs_result_t(-2); // Specified parameter is not valid (e.g. null value of callback, invalid combination of flags).
  SCS_RESULT_already_registered = scs_result_t(-3); // There is already a registered callback for the specified function (e.g. event/channel).
  SCS_RESULT_not_found          = scs_result_t(-4); // Specified item (e.g. channel) was not found.
  SCS_RESULT_unsupported_type   = scs_result_t(-5); // Specified value type is not supported (e.g. channel does not provide that value type).
  SCS_RESULT_not_now            = scs_result_t(-6); // Action (event/callback registration) is not allowed in the current state. Indicates incorrect use of the api.
  SCS_RESULT_generic_error      = scs_result_t(-7); // Error not convered by other existing code.

// Types of messages printed to log.
type
  scs_log_type_t = scs_s32_t;
  p_scs_log_type_t = ^scs_log_type_t;

const
  SCS_LOG_TYPE_message  = scs_log_type_t(0);
  SCS_LOG_TYPE_warning  = scs_log_type_t(1);
  SCS_LOG_TYPE_error    = scs_log_type_t(2);

(**
 * @brief Logs specified message to the game log.
 *
 * @param type Type of message. Controls generated prefixes and colors in console.
 * @param message Message to log.
 *)
type
  scs_log_t = procedure(const aType: scs_log_type_t; const aMessage: scs_string_t); stdcall;

// Common initialization structures.

(**
 * @brief Initialization parameters common to most APIs provided
 * by the SDK.
 *)
type
  scs_sdk_init_params_v100_t = Record
    (**
     * @brief Name of the game for display purposes.
     *
     * This is UTF8 encoded string containing name of the game
     * for display to the user. The exact format is not defined,
     * might be changed between versions and should be not parsed.
     *
     * This pointer will be never NULL.
     *)
    game_name:    scs_string_t;
    (**
     * @brief Identification of the game.
     *
     * If the library wants to identify the game to do any
     * per-game configuration, this is the field which should
     * be used.
     *
     * This string contains only following characters:
     * @li lower-cased letters
     * @li digits
     * @li underscore
     *
     * This pointer will be never NULL.
     *)
    game_id:      scs_string_t;
    (**
     * @brief Version of the game for purpose of the specific api
     * which is being initialized.
     *
     * Does NOT match the patch level of the game.
     *)
    game_version: scs_u32_t;
{$IFDEF SCS_ARCHITECTURE_x64}
    (**
     * @brief Explicit alignment for the 64 bit pointer.
     *)
    _padding:     scs_u32_t;
{$ENDIF}
    (**
     * @brief Function used to write messages to the game log.
     *
     * Each message is printed on a separate line.
     *
     * This pointer will be never NULL.
     *)
    log:          scs_log_t;
  end;
  p_scs_sdk_init_params_v100_t = ^scs_sdk_init_params_v100_t;

// Routines for API strings conversions. 
Function APIStringToTelemetryString(const Str: scs_string_t): TelemetryString;
Function TelemetryStringToAPIString(const Str: TelemetryString): scs_string_t;
procedure APIStringFree(var Str: scs_string_t);
Function TelemetryStringDecode(const Str: TelemetryString): String;
Function TelemetryStringEncode(const Str: String): TelemetryString;

// Routines replacing some of the C macros functionality.
Function SCSCheckSize(ActualSize,{%H-}Expected32,{%H-}Expected64: Cardinal): Boolean;

Function SCSMakeVersion(Major, Minor: scs_u16_t): scs_u32_t;
Function SCSGetMajorVersion(Version: scs_u32_t): scs_u16_t;
Function SCSGetMinorVersion(Version: scs_u32_t): scs_u16_t;
Function SCSGetVersionAsString(Version: scs_u32_t): String;

{=== scssdk_value.pas =========================================================}
(**
 * @file scssdk_value.h
 *
 * @brief Structures representing varying type values in the SDK.
 *)

type
  scs_value_type_t = scs_u32_t;
  p_scs_value_type_t = ^scs_value_type_t;

const
  SCS_VALUE_TYPE_INVALID    = scs_value_type_t(0);
  SCS_VALUE_TYPE_bool       = scs_value_type_t(1);
  SCS_VALUE_TYPE_s32        = scs_value_type_t(2);
  SCS_VALUE_TYPE_u32        = scs_value_type_t(3);
  SCS_VALUE_TYPE_u64        = scs_value_type_t(4);
  SCS_VALUE_TYPE_float      = scs_value_type_t(5);
  SCS_VALUE_TYPE_double     = scs_value_type_t(6);
  SCS_VALUE_TYPE_fvector    = scs_value_type_t(7);
  SCS_VALUE_TYPE_dvector    = scs_value_type_t(8);
  SCS_VALUE_TYPE_euler      = scs_value_type_t(9);
  SCS_VALUE_TYPE_fplacement = scs_value_type_t(10);
  SCS_VALUE_TYPE_dplacement = scs_value_type_t(11);
  SCS_VALUE_TYPE_string     = scs_value_type_t(12);
  SCS_VALUE_TYPE_LAST       = SCS_VALUE_TYPE_string; {SCS_VALUE_TYPE_string}

(**
 * @name Simple data types.
 *)
type
//@{
  scs_value_bool_t = Record
    value:  scs_u8_t; //< Nonzero value is true, zero false.
  end;
  p_scs_value_bool_t = ^scs_value_bool_t;

  scs_value_s32_t = Record
    value:  scs_s32_t;
  end;
  p_scs_value_s32_t = ^scs_value_s32_t;

  scs_value_u32_t = Record
    value:  scs_u32_t;
  end;
  p_scs_value_u32_t = ^scs_value_u32_t;

  scs_value_u64_t = Record
    value:  scs_u64_t;
  end;
  p_scs_value_u64_t = ^scs_value_u64_t;

  scs_value_float_t = Record
    value:  scs_float_t;
  end;
  p_scs_value_float_t = ^scs_value_float_t;

  scs_value_double_t = Record
    value:  scs_double_t;
  end;
  p_scs_value_double_t = ^scs_value_double_t;
//@}

(**
 * @brief String value.
 *
 * The provided value is UTF8 encoded however in some documented
 * cases only limited ASCII compatible subset might be present.
 *
 * The pointer is never NULL.
 *)
  scs_value_string_t = Record
    value:  scs_string_t;
  end;
  p_scs_value_string_t = ^scs_value_string_t;

(**
 * @name Vector types.
 *
 * In local space the X points to right, Y up and Z backwards.
 * In world space the X points to east, Y up and Z south.
 *)
//@{
  scs_value_fvector_t = Record
    x:  scs_float_t;
    y:  scs_float_t;
    z:  scs_float_t;
  end;
  p_scs_value_fvector_t = ^scs_value_fvector_t;

  scs_value_dvector_t = Record
    x:  scs_double_t;
    y:  scs_double_t;
    z:  scs_double_t;
  end;
  p_scs_value_dvector_t = ^scs_value_dvector_t;
//@}

(**
 * @brief Orientation of object.
 *)
  scs_value_euler_t = Record
    (**
     * @name Heading.
     *
     * Stored in unit range where <0,1) corresponds to <0,360).
     *
     * The angle is measured counterclockwise in horizontal plane when looking
     * from top where 0 corresponds to forward (north), 0.25 to left (west),
     * 0.5 to backward (south) and 0.75 to right (east).
     *)
    heading:  scs_float_t;
    (**
     * @name Pitch
     *
     * Stored in unit range where <-0.25,0.25> corresponds to <-90,90>.
     *
     * The pitch angle is zero when in horizontal direction,
     * with positive values pointing up (0.25 directly to zenith),
     * and negative values pointing down (-0.25 directly to nadir).
     *)
    pitch:    scs_float_t;
    (**
     * @name Rool
     *
     * Stored in unit range where <-0.5,0.5> corresponds to <-180,180>.
     *
     * The angle is measured in counterclockwise when looking in direction of
     * the roll axis.
     *)
    roll:     scs_float_t;
  end;
  p_scs_value_euler_t = ^scs_value_euler_t;

(**
 * @name Combination of position and orientation.
 *)
//@{
  scs_value_fplacement_t = Record
    position:     scs_value_fvector_t;
    orientation:  scs_value_euler_t;
  end;
  p_scs_value_fplacement_t = ^scs_value_fplacement_t;

  scs_value_dplacement_t = Record
    position:     scs_value_dvector_t;
    orientation:  scs_value_euler_t;
    _padding:     scs_u32_t; // Explicit padding.
  end;
  p_scs_value_dplacement_t = ^scs_value_dplacement_t;
//@}

(**
 * @brief Varying type storage for values.
 *)
  scs_value_t = Record
    (**
     * @brief Type of the value.
     *)
    _type:    scs_value_type_t;   //"type" is reserved word in pascal
    (**
     * @brief Explicit alignment for the union.
     *)
    _padding: scs_u32_t;
    (**
     * @brief Storage.
     *)
    Case Integer of
      0:  (value_bool:       scs_value_bool_t);
      1:  (value_s32:        scs_value_s32_t);
      2:  (value_u32:        scs_value_u32_t);
      3:  (value_u64:        scs_value_u64_t);
      4:  (value_float:      scs_value_float_t);
      5:  (value_double:     scs_value_double_t);
      6:  (value_fvector:    scs_value_fvector_t);
      7:  (value_dvector:    scs_value_dvector_t);
      8:  (value_euler:      scs_value_euler_t);
      9:  (value_fplacement: scs_value_fplacement_t);
     10:  (value_dplacement: scs_value_dplacement_t);
     11:  (value_string:     scs_value_string_t);
  end;
  p_scs_value_t = ^scs_value_t;

(**
 * @brief Combination of value and its name.
 *)
  scs_named_value_t = Record
    (**
     * @brief Name of this value.
     *
     * ASCII subset of UTF-8.
     *)
    name:   scs_string_t;
    (**
     * @brief Zero-based index of the value for array-like values.
     *
     * For non-array values it is set to SCS_U32_NIL.
     *)
    index:  scs_u32_t;
{$IFDEF SCS_ARCHITECTURE_x64}
    (**
     * @brief Explicit 8-byte alignment for the value part.
     *)
    _padding: scs_u32_t;
{$ENDIF}
    (**
     * @brief The value itself.
     *)
    value:  scs_value_t;
  end;
  p_scs_named_value_t = ^scs_named_value_t;

{=== scssdk_telemetry_event.pas ===============================================}
(**
 * @file scssdk_telemetry_event.h
 *
 * @brief Telemetry SDK - events.
 *)

type
  scs_event_t = scs_u32_t;
  p_scs_event_t = ^scs_event_t;

(**
 * @name Telemetry event types.
 *)
//{
const
(**
 * @brief Used to mark invalid value of event type.
 *)
  SCS_TELEMETRY_EVENT_invalid       = scs_event_t(0);

(**
 * @brief Generated before any telemetry data for current frame.
 *
 * The event_info parameter for this event points to
 * scs_telemetry_frame_start_t structure.
 *)
  SCS_TELEMETRY_EVENT_frame_start   = scs_event_t(1);

(**
 * @brief Generated after all telemetry data for current frame.
 *)
  SCS_TELEMETRY_EVENT_frame_end     = scs_event_t(2);

(**
 * @brief Indicates that the game entered paused state (e.g. menu)
 *
 * If the recipient generates some form of force feedback effects,
 * it should probably stop them until SCS_TELEMETRY_EVENT_started
 * event is received.
 *
 * After sending this event, the game stop sending telemetry data
 * unless specified otherwise in description of specific telemetry.
 * The frame start and event events are still generated.
 *)
  SCS_TELEMETRY_EVENT_paused        = scs_event_t(3);

(**
 * @brief Indicates that the player is now driving.
 *)
  SCS_TELEMETRY_EVENT_started       = scs_event_t(4);

(**
 * @brief Provides set of attributes which change only
 * in special situations (e.g. parameters of the vehicle).
 *
 * The event_info parameter for this event points to
 * scs_telemetry_configuration_t structure.
 *
 * The initial configuration info is delivered to the plugin
 * after its scs_telemetry_init() function succeeds and before
 * any other callback is called. If the the plugin is interested
 * in the configuration info, it must register for this event
 * during its initialization call to ensure that it does
 * not miss it. Future changes in configuration are
 * delivered as described in the event sequence bellow.
 *)
  SCS_TELEMETRY_EVENT_configuration = scs_event_t(5);

//@}

// Sequence of events during frame.
//
// @li Optionally one or more CONFIGURATION events if the configuration changed.
// @li Optionally one from PAUSED or STARTED if there was change since last frame.
// @li FRAME_START
// @li Cannel callbacks
// @li FRAME_END

(**
 * @brief Indicates that timers providing the frame timing info
 * were restarted since last frame.
 *
 * When timer is restarted, it will start counting from zero.
 *)
  SCS_TELEMETRY_FRAME_START_FLAG_timer_restart = scs_u32_t($00000001);

(**
 * @brief Parameters the for SCS_TELEMETRY_EVENT_frame_start event callback.
 *)
type
  scs_telemetry_frame_start_t = Record
    (**
     * @brief Additional information about this event.
     *
     * Combination of SCS_TELEMETRY_FRAME_START_FLAG_* values.
     *)
    flags:                  scs_u32_t;
    (**
     * @brief Explicit alignment for the 64 bit timestamps.
     *)
    _padding:               scs_u32_t;
    (**
     * @brief Time controlling the visualization.
     *
     * Its step changes depending on rendering FPS.
     *)
    render_time:            scs_timestamp_t;
    (**
     * @brief Time controlling the physical simulation.
     *
     * Usually changes with fixed size steps so it oscilates
     * around the render time. This value changes even if the
     * physics simulation is currently paused.
     *)
    simulation_time:        scs_timestamp_t;
    (**
     * @brief Similar to simulation time however it stops
     * when the physics simulation is paused.
     *)
    paused_simulation_time: scs_timestamp_t;
  end;
  p_scs_telemetry_frame_start_t = ^scs_telemetry_frame_start_t;

(**
 * @brief Parameters for the SCS_TELEMETRY_EVENT_configuration event callback.
 *)
  scs_telemetry_configuration_t = Record
    (**
     * @brief Set of logically grouped configuration parameters this
     * event describes (e.g. truck configuration, trailer configuration).
     *
     * See SCS_TELEMETRY_CONFIGURATION_ID_* constants for the game in question.
     *
     * This pointer will be never NULL.
     *)
    id:         scs_string_t;
    (**
     * @brief Array of individual attributes.
     *
     * The array is terminated by entry whose name pointer is set to NULL.
     *
     * Names of the attributes are the SCS_TELEMETRY_ATTRIBUTE_ID_* constants
     * for the game in question.
     *
     * This pointer will be never NULL.
     *)
    attributes: p_scs_named_value_t;
  end;
  p_scs_telemetry_configuration_t = ^scs_telemetry_configuration_t;

(**
 * @brief Type of function registered to be called for event.
 *
 * @param event Event in question. Allows use of single callback with  more than one event.
 * @param event_info Structure with additional event information about the event.
 * @param context Context information passed during callback registration.
 *)
  scs_telemetry_event_callback_t = procedure(event: scs_event_t; event_info: Pointer; context: scs_context_t); stdcall;

(**
 * @brief Registers callback to be called when specified event happens.
 *
 * At most one callback can be registered for each event.
 *
 * This funtion can be called from scs_telemetry_init or from within any
 * event callback other than the callback for the event itself.
 *
 * @param event Event to register for.
 * @param callback Callback to register.
 * @param context Context value passed to the callback.
 * @return SCS_RESULT_ok on successful registration. Error code otherwise.
 *)
  scs_telemetry_register_for_event_t = Function(event: scs_event_t; callback: scs_telemetry_event_callback_t; context: scs_context_t): scs_result_t; stdcall;

(**
 * @brief Unregisters callback registered for specified event.
 *
 * This function can be called from scs_telemetry_shutdown, scs_telemetry_init
 * or from within any event callback. Including callback of the event itself.
 * Any event left registered after scs_telemetry_shutdown ends will
 * be unregistered automatically.
 *
 * @param event Event to unregister from.
 * @return SCS_RESULT_ok on successful unregistration. Error code otherwise.
 *)
  scs_telemetry_unregister_from_event_t = Function(event: scs_event_t): scs_result_t; stdcall;

{=== scssdk_telemetry_channel.pas =============================================}
(**
 * @file scssdk_telemetry_channel.h
 *
 * @brief Telemetry SDK - channels.
 *)

(**
 * @name Telemetry channel flags.
 *)
//{
const
(**
 * @brief No specific flags.
 *)
  SCS_TELEMETRY_CHANNEL_FLAG_none       = scs_u32_t($00000000);

(**
 * @brief Call the callback even if the value did not change.
 *
 * The default behavior is to only call the callback if the
 * value changes. Note that there might be some special situations
 * where the callback might be called even if the value did not
 * change and this flag is not present. For example when the
 * provider of the channel value is reconfigured or when the value
 * changes so frequently that filtering would be only waste of time.
 *
 * Note that even this flag does not guarantee that the
 * callback will be called. For example it might be not called
 * when the value is currently unavailable and the
 * SCS_TELEMETRY_CHANNEL_FLAG_no_value flag was not provided.
 *)
  SCS_TELEMETRY_CHANNEL_FLAG_each_frame = scs_u32_t($00000001);

(**
 * @brief Call the callback even if the value is currently
 * unavailable.
 *
 * By default the callback is only called when the value is
 * available. If this flag is specified, the callback will be
 * called even when the value is unavailable. In that case
 * the value parameter of the callback will be set to NULL.
 *)
  SCS_TELEMETRY_CHANNEL_FLAG_no_value   = scs_u32_t($00000002);

//@}

type
(**
 * @brief Type of function registered to be called with value of single telemetry channel.
 *
 * @param name Name of the channel. Intended for debugging purposes only.
 * @param index Index of entry for array-like channels.
 * @param value Current value of the channel. Will use the type provided during the registration.
 *        Will be NULL if and only if the SCS_TELEMETRY_CHANNEL_FLAG_no_value flag was specified
 *        during registration and the value is currently unavailable.
 * @param context Context information passed during callback registration.
 *)
  scs_telemetry_channel_callback_t = procedure(name: scs_string_t; index: scs_u32_t; value: p_scs_value_t; context: scs_context_t); stdcall;

(**
 * @brief Registers callback to be called with value of specified telemetry channel.
 *
 * At most one callback can be registered for each combination of channel name, index and type.
 *
 * Note that order in which the registered callbacks are called is undefined.
 *
 * This funtion can be called from scs_telemetry_init or from within any
 * event (NOT channel) callback.
 *
 * @param name Name of channel to register to.
 * @param index Index of entry for array-like channels. Set to SCS_U32_NIL for normal channels.
 * @param type Desired type of the value. Only some types are supported (see documentation of specific channel). If the channel can not be returned using that type a SCS_RESULT_unsupported_type will be returned.
 * @param flags Flags controlling delivery of the channel.
 * @param callback Callback to register.
 * @param context Context value passed to the callback.
 * @return SCS_RESULT_ok on successful registration. Error code otherwise.
 *)
  scs_telemetry_register_for_channel_t = Function(name: scs_string_t; index: scs_u32_t; _type: scs_value_type_t; flags: scs_u32_t; callback: scs_telemetry_channel_callback_t; context: scs_context_t): scs_result_t; stdcall;

(**
 * @brief Unregisters callback registered for specified telemetry channel.
 *
 * This function can be called from scs_telemetry_shutdown, scs_telemetry_init
 * or from within any event (NOT channel) callback. Any channel left registered
 * after scs_telemetry_shutdown ends will be unregistered automatically.
 *
 * @param name Name of channel to register from.
 * @param index Index of entry for array-like channels. Set to SCS_U32_NIL for normal channels.
 * @param type Type of value to unregister from.
 * @return SCS_RESULT_ok on successful unregistration. Error code otherwise.
 *)
  scs_telemetry_unregister_from_channel_t = Function(name: scs_string_t; index: scs_u32_t; _type: scs_value_type_t): scs_result_t; stdcall;

{=== scssdk_telemetry.pas =====================================================}
(**
 * @file scssdk_telemetry.h
 *
 * @brief Telemetry SDK.
 *)

(**
 * @name Versions of the telemetry SDK
 *
 * Changes in the major version indicate incompatible changes in the API.
 * Changes in the minor version indicate additions (e.g. more events, defined
 * types as long layout of existing fields in scs_value_t does not change).
 *)
//@{
const
  SCS_TELEMETRY_VERSION_1_00    = (1 shl 16) or 0 {0x00010000};
  SCS_TELEMETRY_VERSION_CURRENT = SCS_TELEMETRY_VERSION_1_00;
//@}

// Structures used to pass additional data to the initialization function.

type
(**
 * @brief Common ancestor to all structures providing parameters to the telemetry
 * initialization.
 *)
//scs_telemetry_init_params_t = Record
//end;
//see further

(**
 * @brief Initialization parameters for the 1.00 version of the telemetry API.
 *)
  scs_telemetry_init_params_v100_t = Record
    (**
     * @brief Common initialization parameters.
     *)
    common:                   scs_sdk_init_params_v100_t;
    (**
     * @name Functions used to handle registration of event callbacks.
     *)
    //@{
    register_for_event:       scs_telemetry_register_for_event_t;
    unregister_from_event:    scs_telemetry_unregister_from_event_t;
    //@}
    (**
     * @name Functions used to handle registration of telemetry callbacks.
     *)
    //@{
    register_for_channel:     scs_telemetry_register_for_channel_t;
    unregister_from_channel:  scs_telemetry_unregister_from_channel_t;
    //@}
  end;
  p_scs_telemetry_init_params_v100_t = ^scs_telemetry_init_params_v100_t;


  scs_telemetry_init_params_t = scs_telemetry_init_params_v100_t;
  p_scs_telemetry_init_params_t = ^scs_telemetry_init_params_t;

// Functions which should be exported by the dynamic library serving as
// recipient of the telemetry.

(**
 * @brief Initializes telemetry support.
 *
 * This function must be provided by the library if it wants to support telemetry API.
 *
 * The engine will call this function with API versions it supports starting from the latest
 * until the function returns SCS_RESULT_ok or error other than SCS_RESULT_unsupported or it
 * runs out of supported versions.
 *
 * At the time this function is called, the telemetry is in the paused state.
 *
 * @param version Version of the API to initialize.
 * @param params Structure with additional initialization data specific to the specified API version.
 * @return SCS_RESULT_ok if version is supported and library was initialized. Error code otherwise.
 *)
  scs_telemetry_init_t = Function(version: scs_u32_t; params: p_scs_telemetry_init_params_t): scs_result_t; stdcall;

(**
 * @brief Shuts down the telemetry support.
 *
 * The engine will call this function if available and if the scs_telemetry_init indicated
 * success.
 *)
  scs_telemetry_shutdown_t = procedure; stdcall;

{=== common/scssdk_telemetry_common_configs.pas ===============================}
(**
 * @file scssdk_telemetry_common_configs.h
 *
 * @brief Telemetry specific constants for configs.
 *
 * This file defines truck specific telemetry constants which
 * might be used by more than one SCS game. See game-specific
 * file to determine which constants are supported by specific
 * game.
 *)

const
(**
 * @brief Configuration of the substances.
 *
 * Attribute index is index of the substance.
 *
 * Supported attributes:
 * @li id
 * TODO: Whatever additional info necessary.
 *)
  SCS_TELEMETRY_CONFIG_substances  = TelemetryString('substances');

(**
 * @brief Static configuration of the controls.
 *
 * @li shifter_type
 *)
  SCS_TELEMETRY_CONFIG_controls = TelemetryString('controls');

(**
 * @brief Configuration of the h-shifter.
 *
 * When evaluating the selected gear, find slot which matches
 * the handle position and bitmask of on/off state of selectors.
 * If one is found, it contains the resulting gear. Otherwise
 * a neutral is assumed.
 *
 * Supported attributes:
 * @li selector_count
 * @li resulting gear index for each slot
 * @li handle position index for each slot
 * @li bitmask of selectors for each slot
 *)
  SCS_TELEMETRY_CONFIG_hshifter = TelemetryString('hshifter');

(**
 * @brief Static configuration of the truck.
 *
 * If empty set of attributes is returned, there is no configured truck.
 *
 * Supported attributes:
 * @li brand_id
 * @li brand
 * @li id
 * @li name
 * @li fuel_capacity
 * @li fuel_warning_factor
 * @li adblue_capacity
 * @li air_pressure_warning
 * @li air_pressure_emergency
 * @li oil_pressure_warning
 * @li water_temperature_warning
 * @li battery_voltage_warning
 * @li rpm_limit
 * @li foward_gear_count
 * @li reverse_gear_count
 * @li retarder_step_count
 * @li cabin_position
 * @li head_position
 * @li hook_position
 * @li wheel_count
 * @li wheel positions for wheel_count wheels
 *)
  SCS_TELEMETRY_CONFIG_truck = TelemetryString('truck');

(**
 * @brief Static configuration of the trailer.
 *
 * If empty set of attributes is returned, there is no configured trailer.
 *
 * Supported attributes:
 * @li id
 * @li cargo_accessory_id
 * @li hook_position
 * @li wheel_count
 * @li wheel offsets for wheel_count wheels
 *)
  SCS_TELEMETRY_CONFIG_trailer = TelemetryString('trailer');

(**
 * @brief Static configuration of the job.
 *
 * If empty set of attributes is returned, there is no job.
 *
 * Supported attributes:
 * @li cargo_id
 * @li cargo
 * @li cargo_mass
 * @li destination_city_id
 * @li destination_city
 * @li source_city_id
 * @li source_city
 * @li destination_company_id
 * @li destination_company
 * @li source_company_id
 * @li source_company
 * @li income - represents expected income for the job without any penalties
 * @li delivery_time
 *)
  SCS_TELEMETRY_CONFIG_job = TelemetryString('job');

 // Attributes

(**
 * @brief Brand id for configuration purposes.
 *
 * Limited to C-identifier characters.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_brand_id = TelemetryString('brand_id');

(**
 * @brief Brand for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_brand = TelemetryString('brand');

(**
 * @brief Name for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_id = TelemetryString('id');

(**
 * @brief Name of cargo accessory for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_cargo_accessory_id = TelemetryString('cargo.accessory.id');

(**
 * @brief Name for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_name = TelemetryString('name');

(**
 * @brief  Fuel tank capacity in litres.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_fuel_capacity = TelemetryString('fuel.capacity');

(**
 * @brief Fraction of the fuel capacity bellow which
 * is activated the fuel warning.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_fuel_warning_factor = TelemetryString('fuel.warning.factor');

(**
 * @brief  AdBlue tank capacity in litres.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_adblue_capacity = TelemetryString('adblue.capacity');

(**
 * @brief Pressure of the air in the tank bellow which
 * the warning activates.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_air_pressure_warning = TelemetryString('brake.air.pressure.warning');

(**
 * @brief Pressure of the air in the tank bellow which
 * the emergency brakes activate.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_air_pressure_emergency = TelemetryString('brake.air.pressure.emergency');

(**
 * @brief Pressure of the oil bellow which the warning activates.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_oil_pressure_warning = TelemetryString('oil.pressure.warning');

(**
 * @brief Temperature of the water above which the warning activates.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_water_temperature_warning = TelemetryString('water.temperature.warning');

(**
 * @brief Voltage of the battery bellow which the warning activates.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_battery_voltage_warning = TelemetryString('battery.voltage.warning');

(**
 * @brief Maximal rpm value.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_rpm_limit = TelemetryString('rpm.limit');

(**
 * @brief Number of forward gears on undamaged truck.
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_forward_gear_count = TelemetryString('gears.forward');

(**
 * @brief Number of reversee gears on undamaged truck.
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_reverse_gear_count = TelemetryString('gears.reverse');

(**
 * @brief Number of steps in the retarder.
 *
 * Set to zero if retarder is not mounted to the truck.
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_retarder_step_count = TelemetryString('retarder.steps');

(**
 * @brief Position of the cabin in the vehicle space.
 *
 * This is position of the joint around which the cabin rotates.
 * This attribute might be not present if the vehicle does not
 * have a separate cabin.
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_cabin_position = TelemetryString('cabin.position');

(**
 * @brief Default position of the head in the cabin space.
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_head_position = TelemetryString('head.position');

(**
 * @brief Position of the trailer connection hook in vehicle
 * space.
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_hook_position = TelemetryString('hook.position');

(**
 * @brief Number of wheels
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_count = TelemetryString('wheels.count');

(**
 * @brief Position of respective wheels in the vehicle space.
 *
 * Type: indexed fvector
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_position = TelemetryString('wheel.position');

(**
 * @brief Is the wheel steerable?
 *
 * Type: indexed bool
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_steerable = TelemetryString('wheel.steerable');

(**
 * @brief Is the wheel physicaly simulated?
 *
 * Type: indexed bool
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_simulated = TelemetryString('wheel.simulated');

(**
 * @brief Radius of the wheel
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_radius = TelemetryString('wheel.radius');

(**
 * @brief Is the wheel powered?
 *
 * Type: indexed bool
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_powered = TelemetryString('wheel.powered');

(**
 * @brief Is the wheel liftable?
 *
 * Type: indexed bool
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_wheel_liftable = TelemetryString('wheel.liftable');

(**
 * @brief Number of selectors (e.g. range/splitter toggles).
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_selector_count = TelemetryString('selector.count');

(**
 * @brief Gear selected when requirements for this h-shifter slot are meet.
 *
 * Type: indexed s32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_slot_gear = TelemetryString('slot.gear');

(**
 * @brief Position of h-shifter handle.
 *
 * Zero corresponds to neutral position. Mapping to physical position of
 * the handle depends on input setup.
 *
 * Type: indexed u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_slot_handle_position = TelemetryString('slot.handle.position');

(**
 * @brief Bitmask of required on/off state of selectors.
 *
 * Only first selector_count bits are relevant.
 *
 * Type: indexed u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_slot_selectors = TelemetryString('slot.selectors');

(**
 * @brief Type of the shifter.
 *
 * One from SCS_SHIFTER_TYPE_* values.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_shifter_type = TelemetryString('shifter.type');

  SCS_SHIFTER_TYPE_arcade     = TelemetryString('arcade');
  SCS_SHIFTER_TYPE_automatic  = TelemetryString('automatic');
  SCS_SHIFTER_TYPE_manual     = TelemetryString('manual');
  SCS_SHIFTER_TYPE_hshifter   = TelemetryString('hshifter');

 // Attributes

(**
 * @brief Id of the cargo for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_cargo_id = TelemetryString('cargo.id');

(**
 * @brief Name of the cargo for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_cargo = TelemetryString('cargo');

(**
 * @brief Mass of the cargo in kilograms.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_cargo_mass = TelemetryString('cargo.mass');

(**
 * @brief Id of the destination city for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_destination_city_id = TelemetryString('destination.city.id');

(**
 * @brief Name of the destination city for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_destination_city = TelemetryString('destination.city');

(**
 * @brief Id of the destination company for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_destination_company_id = TelemetryString('destination.company.id');

(**
 * @brief Name of the destination company for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_destination_company = TelemetryString('destination.company');

(**
 * @brief Id of the source city for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_source_city_id = TelemetryString('source.city.id');

(**
 * @brief Name of the source city for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_source_city = TelemetryString('source.city');

(**
 * @brief Id of the source company for internal use by code.
 *
 * Limited to C-identifier characters and dots.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_source_company_id = TelemetryString('source.company.id');

(**
 * @brief Name of the source company for display purposes.
 *
 * Localized using the current in-game language.
 *
 * Type: string
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_source_company = TelemetryString('source.company');

(**
 * @brief Reward in internal game-specific currency.
 *
 * For detailed information about the currency see "Game specific units"
 * documentation in scssdk_telemetry_<game_id>.h
 *
 * Type: u64
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_income = TelemetryString('income');

(**
 * @brief Absolute in-game time of end of job delivery window.
 *
 * Delivering the job after this time will cause it be late.
 *
 * See SCS_TELEMETRY_CHANNEL_game_time for more info about absolute time.
 * Time remaining for delivery can be obtained like (delivery_time - game_time).
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CONFIG_ATTRIBUTE_delivery_time = TelemetryString('delivery.time');

{=== common/scssdk_telemetry_common_channels.pas ==============================}
(**
 * @file scssdk_telemetry_common_channels.h
 *
 * @brief Telemetry specific channels which might be used by more than one game.
 *)

const
(**
 * @brief Scale applied to distance and time to compensate
 * for the scale of the map (e.g. 1s of real time corresponds to local_scale
 * seconds of simulated game time).
 *
 * Games which use real 1:1 maps will not provide this
 * channel.
 *
 * Type: float
 *)
  SCS_TELEMETRY_CHANNEL_local_scale = TelemetryString('local.scale');

(**
 * @brief Absolute in-game time.
 *
 * Represented in number of in-game minutes since beginning (i.e. 00:00)
 * of the first in-game day.
 *
 * Type: u32
 *)
  SCS_TELEMETRY_CHANNEL_game_time = TelemetryString('game.time');

(**
 * @brief Time until next rest stop.
 *
 * When the fatique simulation is disabled, the behavior of this channel
 * is implementation dependent. The game might provide the value which would
 * apply if it was enabled or provide no value at all.
 *
 * Represented in in-game minutes.
 *
 * Type: s32
 *)
  SCS_TELEMETRY_CHANNEL_next_rest_stop = TelemetryString('rest.stop');

{=== common/scssdk_telemetry_trailer_common_channels.pas ======================}
(**
 * @file scssdk_telemetry_trailer_common_channels.h
 *
 * @brief Trailer telemetry specific constants for channels.
 *
 * See scssdk_telemetry_truck_common_channels.h for more info.
 *)

const
(**
 * @brief Is the trailer connected to the truck?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRAILER_CHANNEL_connected                   = TelemetryString('trailer.connected');

(**
 * @name Channels similar to the truck ones
 *
 * See scssdk_telemetry_truck_common_channels.h for description of
 * corresponding truck channels
 *)
//@{
  SCS_TELEMETRY_TRAILER_CHANNEL_world_placement             = TelemetryString('trailer.world.placement');
  SCS_TELEMETRY_TRAILER_CHANNEL_local_linear_velocity       = TelemetryString('trailer.velocity.linear');
  SCS_TELEMETRY_TRAILER_CHANNEL_local_angular_velocity      = TelemetryString('trailer.velocity.angular');
  SCS_TELEMETRY_TRAILER_CHANNEL_local_linear_acceleration   = TelemetryString('trailer.acceleration.linear');
  SCS_TELEMETRY_TRAILER_CHANNEL_local_angular_acceleration  = TelemetryString('trailer.acceleration.angular');

// Damage.

  SCS_TELEMETRY_TRAILER_CHANNEL_wear_chassis                = TelemetryString('trailer.wear.chassis');

// Wheels.

  SCS_TELEMETRY_TRAILER_CHANNEL_wheel_susp_deflection       = TelemetryString('trailer.wheel.suspension.deflection');
  SCS_TELEMETRY_TRAILER_CHANNEL_wheel_on_ground             = TelemetryString('trailer.wheel.on_ground');
  SCS_TELEMETRY_TRAILER_CHANNEL_wheel_substance             = TelemetryString('trailer.wheel.substance');
  SCS_TELEMETRY_TRAILER_CHANNEL_wheel_velocity              = TelemetryString('trailer.wheel.angular_velocity');
  SCS_TELEMETRY_TRAILER_CHANNEL_wheel_steering              = TelemetryString('trailer.wheel.steering');
  SCS_TELEMETRY_TRAILER_CHANNEL_wheel_rotation              = TelemetryString('trailer.wheel.rotation');
//@}

{=== common/scssdk_telemetry_truck_common_channels.pas ========================}
(**
 * @file scssdk_telemetry_truck_common_channels.h
 *
 * @brief Truck telemetry specific constants for channels.
 *
 * This file defines truck specific telemetry constants which
 * might be used by more than one SCS game. See game-specific
 * file to determine which constants are supported by specific
 * game.
 *
 * Unless state otherwise, following rules apply.
 * @li Whenever channel has float based type (float, fvector, fplacement)
 *     is can also provide double based values (double, dvector, dplacement)
 *     and vice versa. Note that using the non-native type might incur
 *     conversion costs or cause precision loss (double->float in
 *     world-space context).
 * @li Whenever channel has u32 type is can also provide u64 value.
 *     Note that using the non-native type might incur conversion costs.
 * @li Whenever channel uses placement based type (dplacement, fplacement),
 *     it also supports euler type containg just the rotational part and
 *     dvector/fvector type containing just the positional part.
 * @li Indexed entries are using zero-based indices.
 *)

// Movement.

const
(**
 * @brief Represents world space position and orientation of the truck.
 *
 * Type: dplacement
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_world_placement             = TelemetryString('truck.world.placement');

(**
 * @brief Represents vehicle space linear velocity of the truck measured
 * in meters per second.
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_local_linear_velocity       = TelemetryString('truck.local.velocity.linear');

(**
 * @brief Represents vehicle space angular velocity of the truck measured
 * in rotations per second.
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_local_angular_velocity      = TelemetryString('truck.local.velocity.angular');

(**
 * @brief Represents vehicle space linear acceleration of the truck measured
 * in meters per second^2
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_local_linear_acceleration   = TelemetryString('truck.local.acceleration.linear');

(**
 * @brief Represents vehicle space angular acceleration of the truck meassured
 * in rotations per second^2
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_local_angular_acceleration  = TelemetryString('truck.local.acceleration.angular');

(**
 * @brief Represents a vehicle space position and orientation delta
 * of the cabin from its default position.
 *
 * Type: fplacement
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_cabin_offset                = TelemetryString('truck.cabin.offset');

(**
 * @brief Represents cabin space angular velocity of the cabin measured
 * in rotations per second.
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_cabin_angular_velocity      = TelemetryString('truck.cabin.velocity.angular');

 (**
 * @brief Represents cabin space angular acceleration of the cabin
 * measured in rotations per second^2
 *
 * Type: fvector
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_cabin_angular_acceleration  = TelemetryString('truck.cabin.acceleration.angular');

(**
 * @brief Represents a cabin space position and orientation delta
 * of the driver head from its default position.
 *
 * Note that this value might change rapidly as result of
 * the user switching between cameras or camera presets.
 *
 * Type: fplacement
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_head_offset                 = TelemetryString('truck.head.offset');

(**
 * @brief Speedometer speed in meters per second.
 *
 * Uses negative value to represent reverse movement.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_speed                       = TelemetryString('truck.speed');

// Powertrain related

(**
 * @brief RPM of the engine.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_engine_rpm                  = TelemetryString('truck.engine.rpm');

(**
 * @brief Gear currently selected in the engine.
 *
 * @li >0 - Forwad gears
 * @li 0 - Neutral
 * @li <0 - Reverse gears
 *
 * Type: s32
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_engine_gear                 = TelemetryString('truck.engine.gear');

// Driving

(**
 * @brief Steering received from input <-1;1>.
 *
 * Note that it is interpreted counterclockwise.
 *
 * If the user presses the steer right button on digital input
 * (e.g. keyboard) this value goes immediatelly to -1.0
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_input_steering              = TelemetryString('truck.input.steering');

(**
 * @brief Throttle received from input <0;1>
 *
 * If the user presses the forward button on digital input
 * (e.g. keyboard) this value goes immediatelly to 1.0
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_input_throttle              = TelemetryString('truck.input.throttle');

(**
 * @brief Brake received from input <0;1>
 *
 * If the user presses the brake button on digital input
 * (e.g. keyboard) this value goes immediatelly to 1.0
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_input_brake                 = TelemetryString('truck.input.brake');

(**
 * @brief Clutch received from input <0;1>
 *
 * If the user presses the clutch button on digital input
 * (e.g. keyboard) this value goes immediatelly to 1.0
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_input_clutch                = TelemetryString('truck.input.clutch');

(**
 * @brief Steering as used by the simulation <-1;1>
 *
 * Note that it is interpreted counterclockwise.
 *
 * Accounts for interpolation speeds and simulated
 * counterfoces for digital inputs.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_effective_steering          = TelemetryString('truck.effective.steering');

(**
 * @brief Throttle pedal input as used by the simulation <0;1>
 *
 * Accounts for the press attack curve for digital inputs
 * or cruise-control input.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_effective_throttle          = TelemetryString('truck.effective.throttle');

(**
 * @brief Brake pedal input as used by the simulation <0;1>
 *
 * Accounts for the press attack curve for digital inputs. Does
 * not contain retarder, parking or motor brake.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_effective_brake             = TelemetryString('truck.effective.brake');

(**
 * @brief Clutch pedal input as used by the simulation <0;1>
 *
 * Accounts for the automatic shifting or interpolation of
 * player input.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_effective_clutch            = TelemetryString('truck.effective.clutch');

(**
 * @brief Speed selected for the cruise control in m/s
 *
 * Is zero if cruise control is disabled.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_cruise_control              = TelemetryString('truck.cruise_control');

// Gearbox related

(**
 * @brief Gearbox slot the h-shifter handle is currently in.
 *
 * 0 means that no slot is selected.
 *
 * Type: u32
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_hshifter_slot               = TelemetryString('truck.hshifter.slot');

(**
 * @brief Enabled state of range/splitter selector toggles.
 *
 * Mapping between the range/splitter functionality and
 * selector index is described by HSHIFTER configuration.
 *
 * Type: indexed bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_hshifter_selector           = TelemetryString('truck.hshifter.select');

 // Brakes.

(**
 * @brief Is the parking brake enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_parking_brake               = TelemetryString('truck.brake.parking');

(**
 * @brief Is the motor brake enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_motor_brake                 = TelemetryString('truck.brake.motor');

(**
 * @brief Current level of the retarder.
 *
 * <0;max> where 0 is disabled retarder and max is maximal
 * value found in TRUCK configuration.
 *
 * Type: u32
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_retarder_level              = TelemetryString('truck.brake.retarder');

(**
 * @brief Pressure in the brake air tank in psi
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_brake_air_pressure          = TelemetryString('truck.brake.air.pressure');

(**
 * @brief Is the air pressure warning active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_brake_air_pressure_warning  = TelemetryString('truck.brake.air.pressure.warning');

(**
 * @brief Are the emergency brakes active as result of low air pressure?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_brake_air_pressure_emergency = TelemetryString('truck.brake.air.pressure.emergency');

(**
 * @brief Temperature of the brakes in degrees celsius.
 *
 * Aproximated for entire truck, not at the wheel level.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_brake_temperature           = TelemetryString('truck.brake.temperature');

// Various = TelemetryString('consumables'

(**
 * @brief Amount of fuel in liters
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_fuel                        = TelemetryString('truck.fuel.amount');

(**
 * @brief Is the low fuel warning active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_fuel_warning                = TelemetryString('truck.fuel.warning');

(**
 * @brief Average consumption of the fuel in liters/km
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_fuel_average_consumption    = TelemetryString('truck.fuel.consumption.average');

(**
 * @brief Amount of AdBlue in liters
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_adblue                      = TelemetryString('truck.adblue');

(**
 * @brief Is the low adblue warning active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_adblue_warning              = TelemetryString('truck.adblue.warning');

(**
 * @brief Average consumption of the adblue in liters/km
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_adblue_average_consumption  = TelemetryString('truck.adblue.consumption.average');

// Oil

(**
 * @brief Pressure of the oil in psi
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_oil_pressure                = TelemetryString('truck.oil.pressure');

(**
 * @brief Is the oil pressure warning active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_oil_pressure_warning        = TelemetryString('truck.oil.pressure.warning');

(**
 * @brief Temperature of the oil in degrees celsius.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_oil_temperature             = TelemetryString('truck.oil.temperature');

// Temperature in various systems.

(**
 * @brief Temperature of the water in degrees celsius.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_water_temperature           = TelemetryString('truck.water.temperature');

(**
 * @brief Is the water temperature warning active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_water_temperature_warning   = TelemetryString('truck.water.temperature.warning');

// Battery

(**
 * @brief Voltage of the battery in volts.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_battery_voltage             = TelemetryString('truck.battery.voltage');

(**
 * @brief Is the battery voltage/not charging warning active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_battery_voltage_warning     = TelemetryString('truck.battery.voltage.warning');

// Enabled state of various elements.

(**
 * @brief Is the electric enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_electric_enabled            = TelemetryString('truck.electric.enabled');

(**
 * @brief Is the engine enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_engine_enabled              = TelemetryString('truck.engine.enabled');

(**
 * @brief Is the left blinker enabled?
 *
 * This represents the logical enable state of the blinker. It
 * it is true as long the blinker is enabled regardless of the
 * physical enabled state of the light (i.e. it does not blink
 * and ignores enable state of electric).
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_lblinker                    = TelemetryString('truck.lblinker');

(**
 * @brief Is the right blinker enabled?
 *
 * This represents the logical enable state of the blinker. It
 * it is true as long the blinker is enabled regardless of the
 * physical enabled state of the light (i.e. it does not blink
 * and ignores enable state of electric).
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_rblinker                    = TelemetryString('truck.rblinker');

(**
 * @brief Is the light in the left blinker currently on?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_lblinker              = TelemetryString('truck.light.lblinker');

(**
 * @brief Is the light in the right blinker currently on?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_rblinker              = TelemetryString('truck.light.rblinker');

(**
 * @brief Are the parking lights enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_parking               = TelemetryString('truck.light.parking');

(**
 * @brief Are the low beam lights enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_low_beam              = TelemetryString('truck.light.beam.low');

(**
 * @brief Are the high beam lights enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_high_beam             = TelemetryString('truck.light.beam.high');

(**
 * @brief Are the auxiliary front lights active?
 *
 * Those lights have several intensity levels:
 * @li 1 - dimmed state
 * @li 2 - full state
 *
 * Type: u32
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_aux_front             = TelemetryString('truck.light.aux.front');

(**
 * @brief Are the auxiliary roof lights active?
 *
 * Those lights have several intensity levels:
 * @li 1 - dimmed state
 * @li 2 - full state
 *
 * Type: u32
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_aux_roof              = TelemetryString('truck.light.aux.roof');

(**
 * @brief Are the beacon lights enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_beacon                = TelemetryString('truck.light.beacon');

(**
 * @brief Is the brake light active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_brake                 = TelemetryString('truck.light.brake');

(**
 * @brief Is the reverse light active?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_light_reverse               = TelemetryString('truck.light.reverse');

(**
 * @brief Are the wipers enabled?
 *
 * Type: bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wipers                      = TelemetryString('truck.wipers');

(**
 * @brief Intensity of the dashboard backlight as factor <0;1>
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_dashboard_backlight         = TelemetryString('truck.dashboard.backlight');

// Wear info.

(**
 * @brief Wear of the engine accessory as <0;1>
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wear_engine                 = TelemetryString('truck.wear.engine');

(**
 * @brief Wear of the transmission accessory as <0;1>
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wear_transmission           = TelemetryString('truck.wear.transmission');

(**
 * @brief Wear of the cabin accessory as <0;1>
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wear_cabin                  = TelemetryString('truck.wear.cabin');

(**
 * @brief Wear of the chassis accessory as <0;1>
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wear_chassis                = TelemetryString('truck.wear.chassis');

(**
 * @brief Average wear across the wheel accessories as <0;1>
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wear_wheels                 = TelemetryString('truck.wear.wheels');

(**
 * @brief The value of the odometer in km.
 *
 * Type: float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_odometer                    = TelemetryString('truck.odometer');

// Wheels.

(**
 * @brief Vertical displacement of the wheel from its
 * neutral position in meters.
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_susp_deflection       = TelemetryString('truck.wheel.suspension.deflection');

(**
 * @brief Is the wheel in contact with ground?
 *
 * Type: indexed bool
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_on_ground             = TelemetryString('truck.wheel.on_ground');

(**
 * @brief Substance bellow the whell.
 *
 * Index of substance as delivered trough SUBSTANCE config.
 *
 * Type: indexed u32
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_substance             = TelemetryString('truck.wheel.substance');

(**
 * @brief Angular velocity of the wheel in rotations per
 * second.
 *
 * Positive velocity corresponds to forward movement.
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_velocity              = TelemetryString('truck.wheel.angular_velocity');

(**
 * @brief Steering rotation of the wheel in rotations.
 *
 * Value is from <-0.25,0.25> range in counterclockwise direction
 * when looking from top (e.g. 0.25 corresponds to left and
 * -0.25 corresponds to right).
 *
 * Set to zero for non-steered wheels.
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_steering              = TelemetryString('truck.wheel.steering');

(**
 * @brief Rolling rotation of the wheel in rotations.
 *
 * Value is from <0.0,1.0) range in which value
 * increase corresponds to forward movement.
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_rotation              = TelemetryString('truck.wheel.rotation');

(**
 * @brief Lift state of the wheel <0;1>
 *
 * For use with simple lifted/non-lifted test or logical
 * visualization of the lifting progress.
 *
 * Value of 0 corresponds to non-lifted axle.
 * Value of 1 corresponds to fully lifted axle.
 *
 * Set to zero or not provided for non-liftable axles.
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_lift                  = TelemetryString('truck.wheel.lift');

(**
 * @brief Vertical displacement of the wheel axle
 * from its normal position in meters as result of
 * lifting.
 *
 * Might have non-linear relation to lift ratio.
 *
 * Set to zero or not provided for non-liftable axles.
 *
 * Type: indexed float
 *)
  SCS_TELEMETRY_TRUCK_CHANNEL_wheel_lift_offset           = TelemetryString('truck.wheel.lift.offset');


{=== eurotrucks2/scssdk_eut2.pas ==============================================}
(**
 * @file scssdk_eut2.h
 *
 * @brief ETS 2 specific constants.
 *)

const
(**
 * @brief Value used in the scs_sdk_init_params_t::game_id to identify this game.
 *)
  SCS_GAME_ID_EUT2 = TelemetryString('eut2');

{=== eurotrucks2/scssdk_telemetry_eut2.pas ====================================}
(**
 * @file scssdk_telemetry_eut2.h
 *
 * @brief ETS 2 telemetry specific constants.
 *)

(**
 * @name Value used in the scs_sdk_init_params_t::game_version
 *
 * Changes in the major version indicate incompatible changes (e.g. changed interpretation
 * of the channel value). Change of major version is highly discouraged, creation of
 * alternative channel is preferred solution if necessary.
 * Changes in the minor version indicate compatible changes (e.g. added channel, more supported
 * value types). Removal of channel is also compatible change however it is recommended
 * to keep the channel with some default value.
 *
 * Changes:
 * 1.01 - added brake_air_pressure_emergency channel and air_pressure_emergency config
 * 1.02 - replaced cabin_orientation channel with cabin_offset channel
 * 1.03 - fixed reporting of invalid index value for wheels.count attribute
 * 1.04 - added lblinker_light and rblinker_light channels
 * 1.05 - fixed content of brand_id and brand attributes
 * 1.06 - fixed index value for selector_count attribute. It is now SCS_U32_NIL as the
 *        attribute is not indexed. For backward compatibility additional copy with
 *        index 0 is also present however it will be removed in the future.
 * 1.07 - fixed calculation of cabin_angular_acceleration channel.
 * 1.08 - a empty truck/trailer configuration event is generated when truck is removed
 *        (e.g. after completion of quick job)
 * 1.09 - added time and job related info
 * 1.10 - added information about liftable axes
 *)
//@{
const
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_00    = (1 shl 16) or 0   {0x00010000};
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_01    = (1 shl 16) or 1   {0x00010001};
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_02    = (1 shl 16) or 2   {0x00010002};
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_03    = (1 shl 16) or 3   {0x00010003};
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_04    = (1 shl 16) or 4   {0x00010004};
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_05    = (1 shl 16) or 5   {0x00010005}; // Patch 1.4
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_06    = (1 shl 16) or 6   {0x00010006};
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_07    = (1 shl 16) or 7   {0x00010007};	// Patch 1.6
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_08    = (1 shl 16) or 8   {0x00010008};	// Patch 1.9
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_09    = (1 shl 16) or 9   {0x00010009};	// Patch 1.14 beta
  SCS_TELEMETRY_EUT2_GAME_VERSION_1_10    = (1 shl 16) or 10  {0x0001000A};	// Patch 1.14
  SCS_TELEMETRY_EUT2_GAME_VERSION_CURRENT = SCS_TELEMETRY_EUT2_GAME_VERSION_1_10;
//@}

// Game specific units.
//
// @li The game uses Euro as internal currency provided
//     by the telemetry unless documented otherwise.

// Channels defined in scssdk_telemetry_common_channels.h,
// scssdk_telemetry_truck_common_channels.h and
// scssdk_telemetry_trailer_common_channels.h are supported
// with following exceptions and limitations as of v1.00:
//
// @li Adblue related channels are not supported.
// @li The fuel_average_consumption is currently mostly static and depends
//     on presence of the trailer and skills of the driver instead
//     of the workload of the engine.
// @li Rolling rotation of trailer wheels is determined from linear
//     movement.
// @li The pressures, temperatures and voltages are not simulated.
//     They are very loosely approximated.

// Configurations defined in scssdk_telemetry_common_configs.h are
// supported with following exceptions and limitations as of v1.00:
//
// @li The localized strings are not updated when different in-game
//     language is selected.

{******************************************************************************}
{******************************************************************************}
{******************************************************************************}

implementation

uses
  SysUtils;

{=== scssdk.pas ===============================================================}

Function APIStringToTelemetryString(const Str: scs_string_t): TelemetryString;
begin
If Assigned(Str) then
  begin
    SetLength(Result,StrLen(PAnsiChar(Str)));
    Move(Str^,PUTF8Char(Result)^,Length(Result));
  end
else Result := '';
end;

//------------------------------------------------------------------------------

Function TelemetryStringToAPIString(const Str: TelemetryString): scs_string_t;
begin
If Length(Str) > 0 then Result := scs_string_t(StrNew(PAnsiChar(Str)))
  else Result := nil;
end;

//------------------------------------------------------------------------------

procedure APIStringFree(var Str: scs_string_t);
begin
If Assigned(Str) then
  begin
    StrDispose(PAnsiChar(Str));
    Str := nil;
  end;
end;

//------------------------------------------------------------------------------

Function TelemetryStringDecode(const Str: TelemetryString): String;
begin
{$IFDEF Unicode}
Result := UTF8Decode(Str);
{$ELSE}
Result := UTF8ToAnsi(Str);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TelemetryStringEncode(const Str: String): TelemetryString;
begin
{$IFDEF Unicode}
Result := UTF8Encode(Str);
{$ELSE}
Result := AnsiToUTF8(Str);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function SCSCheckSize(ActualSize, Expected32, Expected64: Cardinal): Boolean;
begin
{$IFDEF SCS_ARCHITECTURE_x64}
  Result := ActualSize = Expected64;
{$ELSE}
  {$IFDEF SCS_ARCHITECTURE_x86}
  Result := ActualSize = Expected32;
  {$ELSE}
  {$MESSAGE FATAL 'Undefined architecture!'}  //better prevent compilation
  Halt(666); //architecture is not known, initiate immediate abnormal termination
  {$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function SCSMakeVersion(Major, Minor: scs_u16_t): scs_u32_t;
begin
Result := (Major shl 16) or Minor;
end;

//------------------------------------------------------------------------------

Function SCSGetMajorVersion(Version: scs_u32_t): scs_u16_t;
begin
Result := (Version shr 16) and $FFFF;
end;

//------------------------------------------------------------------------------

Function SCSGetMinorVersion(Version: scs_u32_t): scs_u16_t;
begin
Result := Version and $FFFF;
end;

//------------------------------------------------------------------------------

Function SCSGetVersionAsString(Version: scs_u32_t): String;
begin
Result := IntToStr(SCSGetMajorVersion(Version)) + '.' + 
          IntToStr(SCSGetMinorVersion(Version));
end;

{******************************************************************************}
{******************************************************************************}
{******************************************************************************}

{$IFDEF AssertTypeSize}
initialization
{=== scssdk.pas ===============================================================}
  Assert(SCSCheckSize(SizeOf(scs_sdk_init_params_v100_t),16,32));

{=== scssdk_value.pas =========================================================}
  Assert(SCSCheckSize(SizeOf(scs_value_bool_t),1,1));
  Assert(SCSCheckSize(SizeOf(scs_value_s32_t),4,4));
  Assert(SCSCheckSize(SizeOf(scs_value_u32_t),4,4));
  Assert(SCSCheckSize(SizeOf(scs_value_u64_t),8,8));
  Assert(SCSCheckSize(SizeOf(scs_value_float_t),4,4));
  Assert(SCSCheckSize(SizeOf(scs_value_double_t),8,8));
  Assert(SCSCheckSize(SizeOf(scs_value_fvector_t),12,12));
  Assert(SCSCheckSize(SizeOf(scs_value_dvector_t),24,24));
  Assert(SCSCheckSize(SizeOf(scs_value_fplacement_t),24,24));
  Assert(SCSCheckSize(SizeOf(scs_value_dplacement_t),40,40));
  Assert(SCSCheckSize(SizeOf(scs_value_string_t),4,8));
  Assert(SCSCheckSize(SizeOf(scs_value_t),48,48));
  Assert(SCSCheckSize(SizeOf(scs_named_value_t),56,64));

{=== scssdk_telemetry_event.pas ===============================================}
  Assert(SCSCheckSize(SizeOf(scs_telemetry_frame_start_t),32,32));
  Assert(SCSCheckSize(SizeOf(scs_telemetry_configuration_t),8,16));

{=== scssdk_telemetry.pas =====================================================}
  Assert(SCSCheckSize(SizeOf(scs_telemetry_init_params_v100_t),32,64));
{$ENDIF}

end.
