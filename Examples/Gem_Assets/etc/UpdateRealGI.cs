using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateRealGI : MonoBehaviour
{
    void Update()
    {
        DynamicGI.UpdateEnvironment();
    }
}
