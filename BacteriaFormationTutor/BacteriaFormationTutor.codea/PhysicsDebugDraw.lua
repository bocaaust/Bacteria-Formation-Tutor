PhysicsDebugDraw = class()

function PhysicsDebugDraw:init()
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.singleCollision = true
end

function PhysicsDebugDraw:addBody(body)
    table.insert(self.bodies,body)
end

function PhysicsDebugDraw:addJoint(joint)
    table.insert(self.joints,joint)
end

function PhysicsDebugDraw:clear()
    -- deactivate all bodies
    
    for i,body in ipairs(self.bodies) do
        body:destroy()
    end
    
    for i,joint in ipairs(self.joints) do
        joint:destroy()
    end
    
    self.bodies = {}
    self.joints = {}
    self.contacts = {}
    self.touchMap = {}
end

function PhysicsDebugDraw:draw()
    
    pushStyle()
    smooth()
    strokeWidth(5)
    stroke(128,0,128)
    
    local gain = 2.0
    local damp = 0.5
    for k,v in pairs(self.touchMap) do
        local worldAnchor = v.body:getWorldPoint(v.anchor)
        local touchPoint = v.tp
        local diff = touchPoint - worldAnchor
        local vel = v.body:getLinearVelocityFromWorldPoint(worldAnchor)
        v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
    end
    
    stroke(0,255,0,255)
    strokeWidth(5)
    for k,joint in pairs(self.joints) do
        local a = joint.anchorA
        local b = joint.anchorB
        -- line(a.x,a.y,b.x,b.y)
    end
    
    stroke(255,255,255,255)
    noFill()
    
    
    for i,body in ipairs(self.bodies) do
        pushMatrix()
        translate(body.x, body.y)
        rotate(body.angle)
        
        if body.type == STATIC then
            stroke(255,255,255,255)
        elseif body.type == DYNAMIC then
            stroke(150,255,150,255)
        elseif body.type == KINEMATIC then
            stroke(150,150,255,255)
        end
        
        if body.shapeType == POLYGON then
            strokeWidth(3.0)
             spriteMode(CENTER)
            if body.sensor then
             --local points = body.points
            -- for j = 1,#points do
              --   a = points[j]
              --   b = points[(j % #points)+1]
               --   line(a.x, a.y, b.x, b.y)
              --end
            sprite("Project:bac2",(body.points[1].x+body.points[3].x)/2,(body.points[1].y+body.points[2].y)/2,100*xw,200*xw)
            else
            sprite("Project:bac",(body.points[1].x+body.points[3].x)/2,(body.points[1].y+body.points[2].y)/2,100*xw,200*xw)
            end
            -- ellipse((body.points[1].x+body.points[3].x)/2,(body.points[1].y+body.points[2].y)/2,100*xw,200*xw)
        elseif body.shapeType == CHAIN or body.shapeType == EDGE then
            strokeWidth(3.0)
            local points = body.points
            for j = 1,#points-1 do
                a = points[j]
                b = points[j+1]
                line(a.x, a.y, b.x, b.y)
            end
        elseif body.shapeType == CIRCLE then
            strokeWidth(3.0)
            line(0,0,body.radius-3,0)
            if body.info == "cocci" or body.info == "moved" then
                spriteMode(CENTER)
                if body.sensor then
                sprite("Project:coc2",0,0,body.radius*2)
                --ellipse(0,0,body.radius*2)
                else
                sprite("Project:coc",0,0,body.radius*2)
                end
            else
                
                ellipse(0,0,body.radius*2,body.radius*4)
            end
        end
        
        popMatrix()
    end
    
    stroke(255, 0, 0, 255)
    fill(255, 0, 0, 255)
    
    for k,v in pairs(self.contacts) do
        for m,n in ipairs(v.points) do
          --  ellipse(n.x, n.y, 10, 10)
        end
    end
    
    popStyle()
end

function PhysicsDebugDraw:touched(touch)
    local touchPoint = vec2(touch.x, touch.y)
    if touch.state == BEGAN then
        for i,body in ipairs(self.bodies) do
            if body.type == DYNAMIC and body:testPoint(touchPoint) and body.sensor == false then
                self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = body:getLocalPoint(touchPoint)}
                return true
            end
        end
    elseif touch.state == MOVING and self.touchMap[touch.id] then
        self.touchMap[touch.id].tp = touchPoint
        return true
    elseif touch.state == ENDED and self.touchMap[touch.id] then
        self.touchMap[touch.id] = nil
        return true;
    end
    return false
end

function PhysicsDebugDraw:find(input)
    for i,body in ipairs(self.bodies) do
        if body == input then
            return i
        end
    end
end

function PhysicsDebugDraw:clearSensors()
    for i,body in ipairs(self.bodies) do
        if body.sensor then
            body:destroy()
            table.remove(self.bodies,self:find(body))
        end
    end
end

function PhysicsDebugDraw:hasSensor()
    for i,body in ipairs(self.bodies) do
        if body.sensor then
            return true
        end
    end
    return false
end

function PhysicsDebugDraw:collide(contact)
    if contact.state == BEGAN and contact.bodyA.info ~= "dead" and contact.bodyB.info ~= "dead" and self.singleCollision then
        if (contact.bodyA.sensor or contact.bodyB.sensor) and ((contact.bodyA.sensor and contact.bodyB.sensor) == false) and contact.bodyA.info == contact.bodyB.info then
            if contact.bodyA.sensor then
                self.singleCollison = false
                contact.bodyB.info = "moved"
                tempx = contact.bodyA.x
                tempy = contact.bodyA.y
                contact.bodyA.info = "dead"

                contact.bodyA:destroy()
                table.remove(self.bodies,self:find(contact.bodyA))
                contact.bodyB.x = tempx
                contact.bodyB.y = tempy
            else
                self.singleCollison = false
                contact.bodyA.info = "moved"
                tempx = contact.bodyB.x
                tempy = contact.bodyB.y
                contact.bodyB.info = "dead"

                contact.bodyB:destroy()
                table.remove(self.bodies,self:find(contact.bodyB))
                contact.bodyA.x = tempx
                contact.bodyA.y = tempy
            end
        else
        self.contacts[contact.id] = contact
        sound(SOUND_POWERUP, 2656)
        if contact.bodyA.info == contact.bodyB.info and contact.bodyB.sensor == false and contact.bodyA.sensor == false then
            local joint = physics.joint(REVOLUTE,contact.bodyA,contact.bodyB,contact.position)
            self:addJoint(joint)
            if self:hasSensor() == false and self.joints[#self.joints].bodyA.info == "moved" then
                self:unMove()
            end
            self.contacts[contact.id] = nil
           -- if self.joints[#self.joints].bodyA.info == "moved" then
              --  if self.joints[#self.joints].bodyA.shapeType == CIRCLE then
               --     self.joints[#self.joints].bodyA.info = "cocci"
               --     self.joints[#self.joints].bodyB.info = "cocci"
               -- else
                 --   print(self.joints[#self.joints].bodyA.shapeType)
                  --  self.joints[#self.joints].bodyA.info = "bacilli"
                  --  self.joints[#self.joints].bodyB.info = "bacilli"
                --end
            --end
        end
        end
    elseif contact.state == MOVING then
        if self.contacts[contact.id] ~= nil and contact.bodyA.info == contact.bodyB.info then
            local joint = physics.joint(REVOLUTE,contact.bodyA,contact.bodyB,contact.position)
            self:addJoint(joint)
        end
        self.contacts[contact.id] = nil
    elseif contact.state == ENDED then
        self.contacts[contact.id] = nil
    end
end

function PhysicsDebugDraw:unMove()
    for i,body in ipairs(self.bodies) do
        if body.info == "moved" then
            if body.shapeType == CIRCLE then
                body.info = "cocci"
            else
                body.info = "bacilli"
            end
        end
    end
end
